# frozen_string_literal: true

require "rails_helper"

RSpec.describe(GoogleDriveInfoSync, type: :command) do
  describe("#perform") do
    before do
      allow(GSuite::Client).to(receive(:new).and_return(google_client))

      described_class.call(google_account.id)
    end

    let(:google_account) { create(:google_account) }

    let(:limit)             { 1_000_000_000 }
    let(:total_usage)       { 100_000_000 }
    let(:drive_usage)       { 50_000_000 }
    let(:drive_trash_usage) { 10_000_000 }

    let(:google_client) do
      instance_double(
        GSuite::Client,
        credentials:      Google::Auth::UserRefreshCredentials.new,
        fetch_drive_info: GSuite::Raw::Drive.new(
          limit:,
          total_usage:,
          drive_usage:,
          drive_trash_usage:
        )
      ).as_null_object
    end

    it("asks GMail to fetch Drive info for the account") do
      expect(google_client).to(have_received(:fetch_drive_info))
    end

    it("updates the account with the retrieved info") do
      google_account.reload
      actual =
        google_account.attributes.slice(
          "storage_limit",
          "storage_total_usage",
          "storage_drive_usage",
          "storage_drive_trash_usage"
        )
      # rubocop:disable Style/StringHashKeys
      expected = {
        "storage_limit"             => limit,
        "storage_total_usage"       => total_usage,
        "storage_drive_usage"       => drive_usage,
        "storage_drive_trash_usage" => drive_trash_usage,
      }
      # rubocop:enable Style/StringHashKeys

      expect(actual).to(eq(expected))
    end
  end
end
