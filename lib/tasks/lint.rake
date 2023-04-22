# frozen_string_literal: true

namespace :lint do
  desc "Run RuboCop"
  task :rubocop do
    sh "bin/rubocop --config=./.rubocop.yml"
  end

  desc "Run haml-lint"
  task :haml_lint do
    sh "bin/haml-lint"
  end

  desc "Run Brakeman"
  task :brakeman do
    sh "bin/brakeman --no-pager"
  end

  desc "Run Fasterer"
  task :fasterer do
    sh "bin/fasterer"
  end

  desc "Run bundler-audit"
  task :bundle_audit do
    sh "bin/bundle-audit update"
    sh "bin/bundle-audit check"
  end

  desc "Run bundle-leak"
  task :bundle_leak do
    sh "bin/bundle-leak check --update"
  end
end

desc "Run all lint tasks"
task lint: %i[
  lint:rubocop
  lint:haml_lint
  lint:brakeman
  lint:fasterer
  lint:bundle_audit
  lint:bundle_leak
]
