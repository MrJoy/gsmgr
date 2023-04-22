# frozen_string_literal: true

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into(:webmock)
  config.filter_sensitive_data("Bearer ya29.blah-blah-meh_meh_meh_meh-blah") do |interaction|
    interaction.request.headers["Authorization"]&.first
  end

  # Don't kvetch about Premailer trying to fetch font CSS sheets.
  # TODO: This will allow the requests through.  That will make our test suite reliant on remote
  # TODO: requests!  We should probably mock the requests instead.
  config.ignore_hosts("use.typekit.net", "fonts.googleapis.com")
end
