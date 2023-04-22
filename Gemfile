# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

LIVE_ENVS = %i[stage prod].freeze

# We let this float to make it easier to deal with hiccups with CircleCI, and order-of-operations
# issues with base image update.
root_dir = File.expand_path(".", __dir__)
raw_ruby_ver = File.read(File.join(root_dir, ".ruby-version")).chomp
ruby_ver = raw_ruby_ver.split(".")[0..1].join(".")
ruby "~> #{ruby_ver}"

################################################################################
# Infrastructure
################################################################################
gem "pg",     "~> 1.1"
gem "puma",   "~> 6.0" # N.B. "Prefork has its problems, but having a known hard cap on machine
                       # resource utilization and hard enforced timeouts are both amazing for
                       # operational stability" -AlexS, on why he uses Unicorn instead of Puma
# rubocop:disable Bundler/GemVersion
RAILS_VERSION_SPECIFIER = ["~> 7.0.3"].freeze
# gem "rails",  "~> 6.1.3", ">= 6.1.3"
# Individual Rails components:
# gem "actioncable", *RAILS_VERSION_SPECIFIER
# gem "actionmailbox", *RAILS_VERSION_SPECIFIER
gem "actionmailer", *RAILS_VERSION_SPECIFIER
gem "actionpack", *RAILS_VERSION_SPECIFIER
# gem "actiontext", *RAILS_VERSION_SPECIFIER
gem "actionview", *RAILS_VERSION_SPECIFIER
# gem "activejob", *RAILS_VERSION_SPECIFIER
gem "activemodel", *RAILS_VERSION_SPECIFIER
gem "activerecord", *RAILS_VERSION_SPECIFIER
# gem "activestorage", *RAILS_VERSION_SPECIFIER
gem "activesupport", *RAILS_VERSION_SPECIFIER
gem "railties", *RAILS_VERSION_SPECIFIER
# rubocop:enable Bundler/GemVersion

# gem 'bcrypt', '~> 3.1.7' # For `has_secure`; automatically included by Devise.
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem "google-apis-calendar_v3",  "~> 0.3"
gem "google-apis-people_v1",    "~> 0.3"
gem "mail",                     "~> 2.8.1"
# gem "oj",                       "~> 3.11" # Fluentd prefers this, and... maaaybe others?
gem "rack-cors",                "~> 2.0.0"
gem "redis",                    "~> 4.8.0"
gem "simple_command",           "~> 1.0.1"

################################################################################
# Asset Pipeline
################################################################################
gem "cssbundling-rails", "~> 1.1.0"  # https://github.com/rails/cssbundling-rails
gem "haml-rails",        "~> 2.0"
gem "jsbundling-rails",  "~> 1.1.1"  # https://github.com/rails/jsbundling-rails
gem "propshaft",         "~> 0.7.0" # https://github.com/rails/propshaft

################################################################################
# Operations
################################################################################
gem "dotenv-rails", "~> 2.7"

################################################################################
# Workflow
################################################################################
gem "bootsnap", ">= 1.4.2", require: false
gem "listen", "~> 3.2"
# rubocop:disable Bundler/GemVersion
gem "pry"
gem "pry-rails"
# rubocop:enable Bundler/GemVersion

################################################################################
# Dev Tools
################################################################################
group :development do
  gem "better_errors",     "~> 2.9.1"
  gem "binding_of_caller", "~> 1.0" # Optional, but necessary to use Better Errors' advanced
                                    # features (REPL, local/instance variable inspection, pretty
                                    # stack frame names).
  # gem "web-console"

  gem "spring",                  "~> 4.0"
  gem "spring-commands-rspec",   "~> 1.0"
  # gem "spring-commands-rubocop", "~> 0.2" # TODO: Look at restoring if/when they update / we fork.
  # gem "spring-watcher-listen",   "~> 2.0" # TODO: Look at restoring if/when they update / we fork.

  # rubocop:disable Bundler/GemVersion
  gem "brakeman",                     require: false
  gem "bundler-audit",                require: false
  gem "bundler-leak",                 require: false

  gem "foreman",                      require: false

  gem "haml_lint",                    require: false

  gem "rubocop", "~> 1.3",            require: false
  gem "rubocop-capybara",             require: false
  gem "rubocop-eightyfourcodes",      require: false
  gem "rubocop-performance",          require: false
  gem "rubocop-rails",                require: false
  gem "rubocop-rake",                 require: false
  gem "rubocop-rspec",                require: false
  gem "rubocop-rubycw",               require: false
  gem "rubocop-thread_safety",        require: false

  gem "fasterer", require: false
  # rubocop:enable Bundler/GemVersion
end

################################################################################
# Tools Useful in Dev _and_ Test
################################################################################
group :development, :test do
  # rubocop:disable Bundler/GemVersion
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  # gem "debug", platforms: %i[mri mingw x64_mingw]
  # rubocop:enable Bundler/GemVersion

  # gem "active_record_query_trace"
  gem "bullet", "~> 7.0"

  gem "annotate", "~> 3.2.0"
end

group :development, :test, :stage do
  # In dev so generators work, and stage so mailer previews are picked up.
  gem "rspec-rails", "~> 6.0.0"
end

################################################################################
# Tools Useful Everywhere Except Test and Prod
################################################################################
# group(:development, *(LIVE_ENVS - [:prod])) do
# end

################################################################################
# Tools Useful in Live Environments
################################################################################
# group(*LIVE_ENVS) do
# end

################################################################################
# Testing Tools
################################################################################
group :test do
  gem "capybara",                 "~> 3.38"
  gem "database_cleaner",         "~> 2.0.1"
  gem "factory_bot_rails",        "~> 6.2.0"
  gem "fakeredis",                "~> 0.8.0", require: "fakeredis/rspec" # Yes, we're using this!
  gem "rails-controller-testing", "~> 1.0.5"
  gem "shoulda",                  "~> 4.0.0"
  gem "simplecov",                "~> 0.22.0"
  gem "super_diff",               "~> 0.10.0", require: "super_diff/rspec-rails"
  gem "test-prof",                "~> 1.1"
  gem "timecop",                  "~> 0.9.1"
  gem "vcr",                      "~> 6.1.0"
  gem "webmock",                  "~> 3.18.1"
end
