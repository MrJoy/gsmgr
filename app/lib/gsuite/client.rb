# frozen_string_literal: true

# Useful docs:
# https://developers.google.com/people
#   https://developers.google.com/people/api/rest
#   https://googleapis.dev/ruby/google-api-client/latest/Google/Apis/PeopleV1.html
# https://developers.google.com/calendar
#   https://developers.google.com/calendar/api/guides/overview
#   https://developers.google.com/calendar/api/v3/reference
#   https://googleapis.dev/ruby/google-api-client/latest/Google/Apis/CalendarV3.html
# https://developers.google.com/drive
#   https://developers.google.com/drive/api/guides/about-sdk
#   https://developers.google.com/drive/api/reference/rest/v3
#   https://googleapis.dev/ruby/google-api-client/latest/Google/Apis/DriveV3.html
#
# rubocop:disable Metrics/ClassLength
class GSuite::Client
  PAGE = 100

  CONTACT_FIELDS               = "emailAddresses,names"
  CONTACT_GROUP_PAGE           = 100_000 # No pagination for this endpoint. No docs on limit.
  CONTACT_GROUP_FIELDS         = "clientData,groupType,metadata,name"
  CONTACT_GROUP_MEMBERS_FIELDS = "clientData"
  BANNED_CONTACT_GROUPS        = %w[myContacts all].freeze # Contains every contact, so just noise.

  NOT_FOUND = "notFound"

  def self.not_found_missing_error?(exc)
    exc.message.starts_with?(NOT_FOUND)
  end

  def initialize(login_hint, request: nil, scopes: nil, credentials: nil, authorizer: nil)
    @login_hint  = login_hint.to_s
    @request     = request
    @authorizer  =
      authorizer.presence || begin
        token_store = GSuite::ActiveRecordTokenStore.new
        Google::Auth::UserAuthorizer.new(GOOGLE_CLIENT_ID,
                                         scopes,
                                         token_store,
                                         nil,
                                         Rails.configuration.google[:project_id])
      end
    @credentials = credentials.presence || @authorizer.get_credentials(@login_hint, @request)

    init_services!
  end

  attr_reader :credentials

  def check_credentials!
    raise Google::Apis::AuthorizationError, "NO CREDENTIALS!" if credentials.nil?
  end

  def authorization_url
    @authorizer.get_authorization_url(login_hint: @login_hint, request: @request)
  end

  def fetch_profile
    check_credentials!

    person = @people_svc.get_person("people/me", person_fields: "metadata,emailAddresses")

    [
      person.metadata.sources.find { |source| source.type == "PROFILE" }.id,
      person.email_addresses.find { |addr| addr.metadata.verified }.value.downcase,
    ]
  end

  def options_for_fetch_contacts(next_page_token, request_sync_token, sync_token)
    options = {
      page_size:     PAGE,
      page_token:    next_page_token,
      person_fields: CONTACT_FIELDS,
    }

    options[:request_sync_token] = true if request_sync_token
    options[:sync_token] = sync_token if sync_token

    options
  end

  def fetch_contacts(request_sync_token: false, sync_token: nil)
    check_credentials!

    contacts = []
    next_page_token = nil
    next_sync_token = nil
    loop do
      options = options_for_fetch_contacts(next_page_token, request_sync_token, sync_token)
      resp = @people_svc.list_person_connections("people/me", **options)

      contacts += resp.connections if resp.connections
      next_page_token = resp.next_page_token
      next_sync_token = resp.next_sync_token if request_sync_token

      break unless next_page_token
    end

    contacts.map! { |contact| GSuite::Raw::Contact.from_google(contact) }

    if request_sync_token
      [contacts, next_sync_token]
    else
      contacts
    end
  end

  def options_for_fetch_contact_groups(next_page_token, sync_token)
    options = {
      page_size:    PAGE,
      page_token:   next_page_token,
      group_fields: CONTACT_GROUP_FIELDS,
    }

    options[:sync_token] = sync_token if sync_token

    options
  end

  def fetch_contact_groups(sync_token: nil)
    check_credentials!

    groups = []
    next_page_token = nil
    next_sync_token = nil
    loop do
      options = options_for_fetch_contact_groups(next_page_token, sync_token)
      resp = @people_svc.list_contact_groups(**options)

      groups += resp.contact_groups if resp.contact_groups
      next_page_token = resp.next_page_token
      next_sync_token = resp.next_sync_token

      break unless next_page_token
    end

    groups.reject! { |group| BANNED_CONTACT_GROUPS.include?(group.name) }

    groups.map! { |group| GSuite::Raw::ContactGroup.from_google(group) }

    [groups, next_sync_token]
  end

  def fetch_contact_group_members(id)
    check_credentials!

    group = @people_svc.get_contact_group("contactGroups/#{id}",
                                          max_members:  CONTACT_GROUP_PAGE,
                                          group_fields: CONTACT_GROUP_MEMBERS_FIELDS)

    group.member_resource_names&.map { |resource_name| resource_name.split("/").last } || []
  end

  def fetch_calendars
    check_credentials!

    calendars       = []
    next_page_token = nil
    next_sync_token = nil
    loop do
      resp = @calendar_svc.list_calendar_lists(
        max_results: PAGE,
        page_token:  next_page_token
      )

      calendars += resp.items if resp.items
      next_page_token = resp.next_page_token
      next_sync_token = resp.next_sync_token

      break unless next_page_token
    end

    [next_sync_token, calendars.map { |cal| GSuite::Raw::Calendar.from_google(cal) }]
  end

  def fetch_drive_info
    check_credentials!

    GSuite::Raw::Drive.from_google(@drive_svc.get_about(fields: "storageQuota"))
  end

  # N.B. We override inspect because it will normally log sensitive things, such as the API token,
  # **and refresh token**!
  def inspect
    to_s
  end

  private

  def init_services!
    @people_svc = Google::Apis::PeopleV1::PeopleServiceService.new
    @people_svc.authorization = @credentials
    apply_timeouts!(@people_svc)

    @calendar_svc = Google::Apis::CalendarV3::CalendarService.new
    @calendar_svc.authorization = @credentials
    apply_timeouts!(@calendar_svc)

    @drive_svc = Google::Apis::DriveV3::DriveService.new
    @drive_svc.authorization = @credentials
    apply_timeouts!(@drive_svc)
  end

  def apply_timeouts!(service)
    service.client_options.open_timeout_sec = 5
    service.client_options.send_timeout_sec = 5
    service.client_options.read_timeout_sec = 50
  end
end
# rubocop:enable Metrics/ClassLength
