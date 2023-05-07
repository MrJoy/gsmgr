# frozen_string_literal: true

require "rails_helper"

# NOTE: To re-record a test, do the following:
# 1. Change `.env.test.local` to have valid client ID & secret for development workload account.
# 2. Make sure you've authorized the GMail account you're planning to use in the development
#    workload account, by going through the authorization flow from your workstation.
# 3. Use the rails console to refresh a valid token with:
#    ```
#    GSuite::Client.new(<google account ID>,
#                       scopes: GoogleAccount.required_scopes).fetch_profile
#    ```
# 4. Modify the values in the `MODIFY FOR RECORD MODE` block:
#   1. Change `let(:playback?)` to return `false`
#   2. Edit the `let(:real_token)` line to return the value you get from the following code:
#      ```
#      GoogleToken.where(google_id: <google account ID>).first.token
#      ```
# 5. Delete the relevant cassette(s) from `spec/cassettes/`
# 6. Run RSpec.
#   * NOTE: If the only failure is that the actual values don't match the expected values, you have
#     succeeded and can go straight to the next step!  If not, then you probably got the preceding
#     steps wrong.
# 7. Edit the cassette to remove actual secrets by searching for "Bearer", and replacing with the
#    string that looks like `ya29.<stuff>` in the `let(:dummy_credentials)` line, and to remove any
#    newly-added token-refresh requests near the top.
# 8. Adjust the expected results as-needed, or adjust the casette to return the current values.
# 9. Revert the changes to the `MODIFY FOR RECORD MODE` block.
# 10. Re-run RSpec to confirm things work.

RSpec.describe(GSuite::Client, type: :lib) do
  subject(:client) { described_class.new(login_hint, request:, credentials:, authorizer:) }

  # MODIFY FOR RECORD MODE:
  let(:playback?)  { true } # Change to false for record mode.
  let(:real_token) { "{\"client_id\":\"835842423632-.....\",...\"}" } # Replace with real value.
  # END RECORD MODE

  let(:token)       { playback? ? "GET_THE_REAL_VALUE_FROM_REDIS" : real_token }
  let(:credentials) { playback? ? dummy_credentials : nil }

  let(:dummy_credentials) do
    credentials = Google::Auth::UserRefreshCredentials.new(
      client_id:     "012345678901-0123456789abcdef00000000000000ff.apps.googleusercontent.com",
      client_secret: "shhhh-itsasecret",
      redirect_uri:  "http://localhost:3000/auth/google/authorize",
      scope:         scopes
    )
    credentials.access_token = "ya29.blah-blah-meh_meh_meh_meh-blah"
    credentials
  end

  let(:login_hint)            { 987_654_321 } # WARNING: Don't use a value that exists locally!
  let(:request)               { nil }
  let(:generated_credentials) { instance_double(Google::Auth::UserRefreshCredentials) }
  let(:authorizer) do
    playback? ? instance_double(Google::Auth::UserAuthorizer) : real_authorizer
  end

  # Used in record mode, but not in playback mode:
  let(:scopes)          { GoogleAccount.required_scopes }
  let(:token_store)     { GSuite::ActiveRecordTokenStore.new }
  let(:real_authorizer) { Google::Auth::UserAuthorizer.new(GOOGLE_CLIENT_ID, scopes, token_store, nil, Rails.configuration.google[:project_id]) } # rubocop:disable Layout/LineLength

  before do
    GoogleToken.create!(google_id: login_hint, token:) unless playback?
  end

  after { Timecop.return }

  describe("#authorization_url") do
    subject(:authorization_url) { client.authorization_url }

    let(:session) { instance_double(ActionDispatch::Request::Session) }
    let(:request) { instance_double(ActionDispatch::Request, session:) }

    it("produces a URL that we can direct the user to for authorization") do
      expected_url = "https://whatever"
      allow(authorizer).to(receive(:get_credentials)
                           .with(login_hint.to_s, request)
                           .and_return(generated_credentials))
      allow(authorizer).to(receive(:get_authorization_url)
                           .with({ login_hint: login_hint.to_s, request: })
                           .and_return(expected_url))

      expect(authorization_url).to(eq(expected_url))
    end
  end

  describe("#fetch_profile") do
    subject(:profile) { client.fetch_profile }

    before do
      Timecop.freeze(Time.zone.local(2020, 7, 8, 15, 0, 6)) if playback?
    end

    it("returns ID, email, and latest history ID for the GSuite account") do
      VCR.use_cassette("google_client_fetch_profile") do
        expect(profile).to(eq(["101241854727239032273", "jon@stuff.work"]))
      end
    end
  end

  describe("#fetch_contacts") do
    subject(:contacts) { client.fetch_contacts }

    before do
      Timecop.freeze(Time.zone.local(2020, 7, 8, 15, 0, 6)) if playback?
    end

    it("returns contacts for the GSuite account") do
      VCR.use_cassette("google_client_fetch_contacts") do
        expect(contacts)
          .to(eql([
                    GSuite::Raw::Contact.new(
                      id:                      "c2135938136224466463",
                      primary_email:           "msmith@mac.com",
                      all_emails:              %w[msmith@mac.com msmith@me.com],
                      display_name:            "Marilyn Smith",
                      family_name:             "Smith",
                      given_name:              "Marilyn",
                      display_name_last_first: "Smith, Marilyn"
                    ),
                    GSuite::Raw::Contact.new(
                      id:                      "c1597419354734556943",
                      primary_email:           "sciandu@gmail.com",
                      all_emails:              %w[
                        sciandu@gmail.com
                        jsmith@mrsmith.com
                        jsmith@me.com
                        jsmith@mac.com
                        jsmith@icloud.com
                      ],
                      display_name:            "Mr. Jon David Smith Esquire",
                      family_name:             "Smith",
                      given_name:              "Jon",
                      middle_name:             "David",
                      display_name_last_first: "Smith, Mr. Jon David, Esquire"
                    ),
                  ]))
      end
    end
  end

  describe("#fetch_contact_groups") do
    subject(:groups) { client.fetch_contact_groups }

    before do
      Timecop.freeze(Time.zone.local(2020, 7, 8, 15, 0, 6)) if playback?
    end

    it("returns contact groups for the GSuite account") do
      VCR.use_cassette("google_client_fetch_contact_groups") do
        expect(groups)
          .to(eql([
                    [
                      GSuite::Raw::ContactGroup.new(
                        id:             "2924db450ca4eed7",
                        name:           "Freeverse",
                        formatted_name: "Freeverse",
                        group_type:     "USER_CONTACT_GROUP",
                        deleted:        nil
                      ),
                      GSuite::Raw::ContactGroup.new(
                        id:             "chatBuddies",
                        name:           "chatBuddies",
                        formatted_name: "Chat contacts",
                        group_type:     "SYSTEM_CONTACT_GROUP",
                        deleted:        nil
                      ),
                      GSuite::Raw::ContactGroup.new(
                        id:             "friends",
                        name:           "friends",
                        formatted_name: "Friends",
                        group_type:     "SYSTEM_CONTACT_GROUP",
                        deleted:        nil
                      ),
                      GSuite::Raw::ContactGroup.new(
                        id:             "family",
                        name:           "family",
                        formatted_name: "Family",
                        group_type:     "SYSTEM_CONTACT_GROUP",
                        deleted:        nil
                      ),
                      GSuite::Raw::ContactGroup.new(
                        id:             "coworkers",
                        name:           "coworkers",
                        formatted_name: "Coworkers",
                        group_type:     "SYSTEM_CONTACT_GROUP",
                        deleted:        nil
                      ),
                      GSuite::Raw::ContactGroup.new(
                        id:             "blocked",
                        name:           "blocked",
                        formatted_name: "Blocked",
                        group_type:     "SYSTEM_CONTACT_GROUP",
                        deleted:        nil
                      ),
                      GSuite::Raw::ContactGroup.new(
                        id:             "starred",
                        name:           "starred",
                        formatted_name: "Starred",
                        group_type:     "SYSTEM_CONTACT_GROUP",
                        deleted:        nil
                      ),
                    ],
                    "EITww5P40v4C",
                  ]))
      end
    end
  end

  describe("#fetch_contact_group_members") do
    subject(:members) { client.fetch_contact_group_members("2924db450ca4eed7") }

    before do
      Timecop.freeze(Time.zone.local(2020, 7, 8, 15, 0, 6)) if playback?
    end

    it("returns contact group members for the given contact group in the GSuite account") do
      VCR.use_cassette("google_client_fetch_contact_group_members") do
        expect(members.sort)
          .to(eql(%w[c5832867659682504457 c6764048178195122168].sort))
      end
    end
  end

  describe("#fetch_drive_info") do
    subject(:info) { client.fetch_drive_info }

    before do
      Timecop.freeze(Time.zone.local(2023, 5, 5, 14, 15, 0)) if playback?
    end

    it("returns storage/quota information for user's account") do
      VCR.use_cassette("google_client_fetch_drive_info") do
        expect(info).to(eq(
                          GSuite::Raw::Drive.new(
                            limit:             16_106_127_360,
                            total_usage:       858_337_910,
                            drive_usage:       858_337_910,
                            drive_trash_usage: 86_585
                          )
                        ))
      end
    end
  end
end
