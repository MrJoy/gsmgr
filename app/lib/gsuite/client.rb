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
#   https://developers.google.com/drive/api/guides/fields-parameter
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

  # Default fields: id, kind, mimeType, name
  #
  # copyRequiresWriterPermission:
  #   "Whether the options to copy, print, or download this file, should be disabled for
  #    readers and commenters."
  # writersCanShare:
  #   "Whether users with only writer permission can modify the file's permissions. Not
  #    populated for items in shared drives."
  #
  # Arrays:
  # * spaces
  # * parents (apparently only one -- but have a sanity check!)
  # * owners (only one, unless we somehow get access to a legacy document of some kind)
  # * permissions
  #
  # Hashes:
  # * shortcutDetails
  # * capabilities
  FILE_FIELDS = %w[
    id
    mimeType
    name
    quotaBytesUsed
    parents
    spaces
    starred
    trashed
    shared
    owners(emailAddress)
    permissions(id,emailAddress,deleted,role,type,pendingOwner,allowFileDiscovery)
    capabilities
    shortcutDetails
    webViewLink
  ].join(",")
  # TODO: Do we care about any of the following?
  # * copyRequiresWriterPermission
  # * writersCanShare
  # * contentRestrictions
  # * labelInfo (as a means of controlling group assignments?)
  FILE_LIST_FIELDS = "nextPageToken,incompleteSearch,files(#{FILE_FIELDS})".freeze

  NOT_FOUND = "notFound"

  def self.not_found_missing_error?(exc)
    exc.message.starts_with?(NOT_FOUND)
  end

  def self.normalize_email(email)
    return if email.nil?

    localpart, domain = email.split("@")
    localpart.delete!(".") # Google ignores dots in email addresses.
    "#{localpart}@#{domain}".downcase
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

  def fetch_files
    check_credentials!

    files             = []
    next_page_token   = nil
    incomplete_search = false
    loop do
      # TODO: Do we care about any of the following options?
      # * `include_items_from_all_drives: true`
      # * `supports_all_drives:           true`
      # * `spaces:                        "drive"`
      resp = @drive_svc.list_files(
        # N.B. `page_size` is ignored when specifying `fields`.
        #
        # Query for folders:
        #   `q: "mimeType = 'application/vnd.google-apps.folder'"`
        #
        # Query for files in a folder:
        #   `q: "parents in '1lYGSyevXLLyJXZEBBhz7mFT_TefnrJIn'"`
        corpora:    "user", # ... drive, allDrives
        fields:     FILE_LIST_FIELDS,
        page_token: next_page_token
      )

      incomplete_search ||= resp.incomplete_search
      files              += resp.files if resp.files
      next_page_token     = resp.next_page_token

      break unless next_page_token
    end

    [incomplete_search, files.map { |file| GSuite::Raw::File.from_google(file) }]
  end

  def create_permission(file_id, email_address, role)
    check_credentials!

    resp = @drive_svc.create_permission(
      file_id,
      Google::Apis::DriveV3::Permission.new(
        type:          "user",
        email_address:,
        role:
      ),
      send_notification_email: false,
      supports_all_drives:     true,
      transfer_ownership:      false
    )

    resp&.id
  end

  def delete_permission(file_id, permission_id)
    check_credentials!

    @drive_svc.delete_permission(
      file_id,
      permission_id,
      supports_all_drives: true
    )
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
