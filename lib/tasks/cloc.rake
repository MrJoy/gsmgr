# frozen_string_literal: true

desc "Run cloc, excluding vendored code, compiled assets, etc."
task :cloc do
  # N.B. Each entry here is a Perl regex!
  off_limits_dirs = %w[
    \.bundle
    \.terraform
    bin
    coverage
    log
    node_modules
    builds
    public
    cassettes
    tmp
    vendor
  ]

  off_limits_files = %w[
    Gemfile\.lock
    .*\.lock\.json
    \.byebug_history
    .*\.log
  ]

  sh [
    "cloc",
    ".",
    "--fullpath",
    "--not-match-d='#{off_limits_dirs.join("|")}'",
    "--not-match-f='#{off_limits_files.join("|")}'",
  ].join(" ")
end
