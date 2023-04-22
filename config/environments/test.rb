# frozen_string_literal: true

require "active_support/core_ext/integer/time"

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  if defined?(Bullet)
    config.after_initialize do
      Bullet.enable        = true
      Bullet.bullet_logger = true
      Bullet.raise         = true # raise an error if n+1 query occurs
    end
  end

  port = ENV.fetch("PORT", 3000)
  config.origins = ["http://localhost:#{port}"]

  config.rails_max_threads = ENV.fetch("RAILS_MAX_THREADS", 4).to_i

  config.google = {
    client_id:             ENV.fetch("GOOGLE_CLIENT_ID", ""),
    client_secret:         ENV.fetch("GOOGLE_CLIENT_SECRET", ""),
    project_id:            ENV.fetch("GOOGLE_PROJECT_ID", ""),
    super_verbose_logging: false,
    log_ts_and_pid:        false,
  }

  config.devise = {
    secret_key:       ENV.fetch("DEVISE_SECRET_KEY", "dummy"),
    bcrypt_stretches: 1,
  }

  # Turn false under Spring and add config.action_view.cache_template_loading = true.
  config.cache_classes = true
  config.eager_load    = ENV["CI"].present?

  config.consider_all_requests_local                     = true
  config.action_controller.perform_caching               = false
  config.action_controller.enable_fragment_cache_logging = true
  config.cache_store                                     = :null_store

  config.action_controller.allow_forgery_protection = false

  config.server_timing = true

  config.require_master_key = false

  config.public_file_server.enabled = true
  # rubocop:disable Style/StringHashKeys
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.to_i}",
  }
  # rubocop:enable Style/StringHashKeys
  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  config.action_mailer.perform_caching       = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options   = {
    protocol: "http",
    host:     "localhost",
    port:,
  }
  config.action_mailer.show_previews   = false
  # config.action_mailer.preview_path    = Rails.root.join("spec", "mailers", "previews")
  config.action_mailer.delivery_method = :test

  config.active_support.report_deprecations             = true
  config.active_support.deprecation                     = :stderr
  config.active_support.disallowed_deprecation          = :raise
  config.active_support.disallowed_deprecation_warnings = []

  config.i18n.fallbacks                     = false
  config.i18n.raise_on_missing_translations = true

  # N.B. If changing any logging config, make sure config/initializers/google.rb is kept in sync!
  # config.colorize_logging = true
  # config.log_level        = :debug
  # config.log_tags         = nil
  # config.log_formatter    = nil
  # logger                  = ActiveSupport::Logger.new($stdout)
  # logger.formatter        = config.log_formatter
  # config.logger           = ActiveSupport::TaggedLogging.new(logger)

  config.active_record.verbose_query_logs             = true
  config.active_record.encryption.primary_key         = ENV.fetch("AR_ENCRYPTION_PRIMARY_KEY", "")
  config.active_record.encryption.deterministic_key   = ENV.fetch("AR_ENCRYPTION_DETERMINISTIC_KEY", "") # rubocop:disable Layout/LineLength
  config.active_record.encryption.key_derivation_salt = ENV.fetch("AR_ENCRYPTION_KEY_DERIVATION_SALT", "") # rubocop:disable Layout/LineLength

  config.assets.quiet   = true
  config.assets.compile = true

  # config.active_record.migration_error             = :page_load
  config.active_record.dump_schema_after_migration = false

  config.action_dispatch.show_exceptions = false
  # rubocop:disable Style/StringHashKeys
  config.action_dispatch.default_headers = {
    "Referrer-Policy"                   => "strict-origin-when-cross-origin",
    "X-Content-Type-Options"            => "nosniff",
    "X-Frame-Options"                   => "SAMEORIGIN", # Needed for mailer previews.
    "X-Permitted-Cross-Domain-Policies" => "none",
    "X-XSS-Protection"                  => "0", # See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-XSS-Protection
  }
  # rubocop:enable Style/StringHashKeys

  config.force_ssl      = false
  config.secure_cookies = false

  config.action_view.annotate_rendered_view_with_filenames = false

  # config.action_cable.disable_request_forgery_protection = false
end
