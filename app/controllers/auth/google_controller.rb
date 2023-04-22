# frozen_string_literal: true

# IMPORTANT: If you change this file, you probably need to change the routes in the `app` repo!
#
# rubocop:disable Metrics/ClassLength
class Auth::GoogleController < ApplicationController
  helper :application

  def authorize
    handle_authorization(auth_google_done_path)
  end

  def callback
    return if handle_error_condition!

    credentials, client, scopes, original_target = setup_callback_state!

    unless check_scopes(scopes)
      redirect_to(auth_google_error_path)
      return
    end

    ensure_credentials!(client)

    handle_callback(client, scopes) do |account|
      authorizer.store_credentials(account.id.to_s, credentials)
    end

    send_user_back(original_target)
  end

  def done
    render("done")
  end

  protected

  def setup_callback_state!
    code, scopes    = extract_callback_state
    credentials     = get_credentials(code, scopes)
    client          = GSuite::Client.new(nil,
                                         request:,
                                         credentials:,
                                         scopes:,
                                         authorizer:)
    original_target = extract_original_target(params[:state])

    [credentials, client, scopes, original_target]
  end

  def handle_authorization(target)
    session[:target] = target

    # Reset the XSRF key so that we can add multiple accounts in a single session.
    session[Google::Auth::WebUserAuthorizer::XSRF_KEY] = nil

    # N.B. Unless we are re-authorizing a known account, we want to use a dummy sentinel value.
    # This is in order to support multiple GSuite accounts without having the tokens all get
    # clobbered in Redis, because the Google token-store functionality uses the hint as a key when
    # storing/retrieving tokens.
    #
    # We want to preserve the following properties:
    # 1. We don't store any tokens associated with the sentinel hint.
    # 2. We can easily determine, by looking at Redis, if we _have_ stored a token under a sentinel
    #    hint.
    # 3. If we do store a token under a sentinel hint, we don't accidentally give user B access to a
    #    GSuite account owned by user A.
    #
    # To achieve this, we do the following:
    # 1. Bypass the normal client library auth flow so we can perform the relevant steps without
    #    storing the token at inconvenient points, and bypass the use of the hint after-the-fact
    #    but before storing the token.
    # 2. Tag the hint with a well-known value that we can search for in Redis easily.
    # 3. Namespace the sentinel with user ID so tokens don't bleed across users.
    #
    # NOTE:  In the event that we are reauthorizing a known account, we want the hint to be the
    # primary email address of the account, so Google will prompt the user to log in with that
    # specifically.  Thus the use of `params[:hint]` here.
    hint = params[:hint] || nil

    client = GSuite::Client.new(hint, request:, scopes: GoogleAccount.required_scopes, authorizer:)
    redirect_to(client.authorization_url, allow_other_host: true)
  end

  def handle_error_condition!
    return false unless params[:error] == "access_denied"

    # TODO: Send people to a page indicating that they need to grant us access to proceed.
    send_user_back(nil)

    true
  end

  def get_credentials(code, scope)
    authorizer.get_credentials_from_code(user_id:  SecureRandom.hex(32),
                                         code:,
                                         scope:,
                                         base_url: request.url)
  end

  def extract_original_target(state)
    parsed_state = JSON.parse(state)
    URI.decode_www_form(parsed_state["current_uri"]).first.last
  rescue StandardError
    nil
  end

  def authorizer
    @authorizer ||=
      begin
        token_store = GSuite::ActiveRecordTokenStore.new

        Google::Auth::WebUserAuthorizer.new(GOOGLE_CLIENT_ID,
                                            GoogleAccount.required_scopes,
                                            token_store,
                                            auth_google_callback_path)
      end
  end

  def send_user_back(original_target, extra_params = {})
    destination = URI(session[:target] || original_target || auth_google_done_path)
    session[:target] = nil

    query = (destination.query ? URI.decode_www_form(destination.query) : []).to_h
    if extra_params.present?
      query.merge!(extra_params)
      destination.query = query.to_query
    end

    redirect_to(destination.to_s)
  end

  def extract_callback_state
    callback_state, _target_url = Google::Auth::WebUserAuthorizer.extract_callback_state(request)
    auth_code                   = callback_state[Google::Auth::WebUserAuthorizer::AUTH_CODE_KEY]
    scopes                      = callback_state[Google::Auth::WebUserAuthorizer::SCOPE_KEY]
                                  &.split(/\s+/)
    [auth_code, scopes]
  end

  def check_scopes(scopes)
    !(GoogleAccount.required_scopes - scopes).length.positive?
  end

  def ensure_credentials!(client)
    return unless client.credentials.nil?

    raise StandardError, "Something went wrong, no credentials received!"
  end

  def handle_callback(client, scopes)
    # The following is derived from `handle_auth_callback`, `get_and_store_credentials_from_code`
    # `get_credentials`, `extract_callback_state`, etc.  I'm copy-pasting here because I couldn't
    # figure out a blessed path that broke the circular problem of "I don't have a login hint until
    # after I've retrieved and used the credentials, but can't retrieve and use the credentials
    # without a login hint."  I'm sorry.

    google_id, email = client.fetch_profile
    email            = email&.downcase

    account = nil
    GoogleAccount.transaction do
      account = GoogleAccount.find_by(google_id:)
      if account.present?
        account.email = email if email.present?

        account.scopes = scopes

        account.save!
      end

      account ||= GoogleAccount.create!(google_id:, email:, scopes:)

      yield(account)
    end
  end
end
# rubocop:enable Metrics/ClassLength
