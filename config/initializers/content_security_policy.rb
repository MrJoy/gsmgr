# frozen_string_literal: true

# rubocop:disable Layout/LineLength

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

# For webpack-dev-server:
webpack_urls = Rails.env.development? ? ["http://localhost:3035", "ws://localhost:3035"] : []

SRC_URLS = ([:self] + webpack_urls).freeze

FONT_SRC_URLS    = ([:data] + SRC_URLS).freeze
IMG_SRC_URLS     = ([:data] + SRC_URLS).freeze
SCRIPT_SRC_URLS  = SRC_URLS
STYLE_SRC_URLS   = SRC_URLS
CONNECT_SRC_URLS = ([:data] + SRC_URLS).freeze

Rails.application.config.content_security_policy do |policy|
  policy.default_src(:self)
  policy.font_src(*FONT_SRC_URLS)
  policy.img_src(*IMG_SRC_URLS)
  policy.object_src(:none)
  policy.script_src(*SCRIPT_SRC_URLS)
  policy.style_src(*STYLE_SRC_URLS)
  policy.connect_src(*CONNECT_SRC_URLS)

  # Specify URI for violation reports; N.B. When implementing this, check for CSP policy overrides
  # in specific controllers!  Notably, the ActiveAdmin dashboard, and GraphiQL controllers!
  # policy.report_uri("/csp-violation-report-endpoint")
end

# https://stackoverflow.com/questions/34078676/access-control-allow-origin-not-allowed-when-credentials-flag-is-true-but
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Credentials
# https://web-in-security.blogspot.com/2017/07/cors-misconfigurations-on-large-scale.html

# https://github.com/cyu/rack-cors
Rails.application.config.middleware.insert_before(0, Rack::Cors) do
  allow do
    origins(*Rails.configuration.origins)

    resource("*", headers: :any, credentials: true, methods: %i[get post patch put])
  end
end

# If you are using UJS then enable automatic nonce generation
# Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Set the nonce only to specific directives
# Rails.application.config.content_security_policy_nonce_directives = %w(script-src)

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true

# rubocop:enable Layout/LineLength
