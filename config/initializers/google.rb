# frozen_string_literal: true

require "redis"

# https://github.com/googleapis/google-auth-library-ruby
require "googleauth"
require "googleauth/web_user_authorizer"
require "googleauth/token_store"
# https://github.com/googleapis/google-api-ruby-client
require "google/apis/people_v1"
require "google/apis/calendar_v3"

GOOGLE_CLIENT_ID = Google::Auth::ClientId.new(
  Rails.configuration.google[:client_id],
  Rails.configuration.google[:client_secret]
)

# rubocop:disable Style/ClassAndModuleChildren,Style/ReturnNil,Style/FormatString,Layout/EmptyLineAfterGuardClause,Style/MethodDefParentheses,Style/OptionHash,Style/TrailingCommaInArguments,Style/MethodCallWithArgsParentheses
module Google
  module Auth
    # Monkey-patch for `Google::Auth::UserAuthorizer` to provide a project ID, so it doesn't wind up
    # shelling out to `gcloud` to get it.  I wish I was joking.
    class UserAuthorizer
      def initialize(client_id, scope, token_store, callback_uri = nil, project_id = nil)
        raise NIL_CLIENT_ID_ERROR if client_id.nil?
        raise NIL_SCOPE_ERROR if scope.nil?

        @client_id = client_id
        @scope = Array(scope)
        @token_store = token_store
        @callback_uri = callback_uri || "/oauth2callback"
        @project_id = project_id
      end

      def get_credentials(user_id, scope = nil)
        saved_token = stored_token user_id
        return nil if saved_token.nil?
        data = MultiJson.load saved_token

        if data.fetch("client_id", @client_id.id) != @client_id.id
          raise format(MISMATCHED_CLIENT_ID_ERROR, data["client_id"], @client_id.id)
        end

        credentials = UserRefreshCredentials.new(
          client_id:     @client_id.id,
          client_secret: @client_id.secret,
          scope:         data["scope"] || @scope,
          access_token:  data["access_token"],
          refresh_token: data["refresh_token"],
          expires_at:    data.fetch("expiration_time_millis", 0) / 1000,
          project_id:    @project_id,
        )
        scope ||= @scope
        return monitor_credentials(user_id, credentials) if credentials.includes_scope?(scope)
        nil
      end

      def get_credentials_from_code options = {}
        user_id = options[:user_id]
        code = options[:code]
        scope = options[:scope] || @scope
        base_url = options[:base_url]
        credentials = UserRefreshCredentials.new(
          client_id:     @client_id.id,
          client_secret: @client_id.secret,
          redirect_uri:  redirect_uri_for(base_url),
          scope:,
          project_id:    @project_id,
        )
        credentials.code = code
        credentials.fetch_access_token!({})
        monitor_credentials user_id, credentials
      end
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren,Style/ReturnNil,Style/FormatString,Layout/EmptyLineAfterGuardClause,Style/MethodDefParentheses,Style/OptionHash,Style/TrailingCommaInArguments,Style/MethodCallWithArgsParentheses

google_log_level = Logger::WARN
# N.B. Uncomment the next line if you want to see what's happening under the hood for every request.
# Be warned:  This is SUUUUUPER verbose!
google_log_level = Logger::DEBUG if Rails.configuration.google[:super_verbose_logging]

# Don't add timestamp/PID info if we're in dev/test environments.
google_log_formatter = nil
google_log_formatter = Logger::Formatter.new if Rails.configuration.google[:log_ts_and_pid]

google_logger           = ActiveSupport::Logger.new($stdout)
google_logger.formatter = google_log_formatter
google_logger.level     = google_log_level
Google::Apis.logger     = ActiveSupport::TaggedLogging.new(google_logger)

Google::Apis::RequestOptions.default.retries = 3
