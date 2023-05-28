# frozen_string_literal: true

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.configuration.sidekiq[:redis_url] }
end

# Worker executing jobs:
Sidekiq.configure_server do |config|
  # SideKiq wants a pool size of at least 10.  Bah.
  pool_size = Rails.configuration.sidekiq[:max_conns]
  config.redis = { size: pool_size, url: Rails.configuration.sidekiq[:redis_url] }

  # config.failures_max_count = 10_000
  # config.failures_default_mode = :exhausted
end

Sidekiq.default_job_options = {
  backtrace: true,
}
