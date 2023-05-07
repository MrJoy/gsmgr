# frozen_string_literal: true

# A simplified representation of Google Drive metadata, as returned by Google.
GSuite::Raw::Drive =
  Struct.new(:limit, :total_usage, :drive_usage, :drive_trash_usage) do
    def initialize(limit:, total_usage:, drive_usage:, drive_trash_usage:)
      super(limit, total_usage, drive_usage, drive_trash_usage)
    end

    def self.from_google(gdrive)
      GSuite::Raw::Drive.new(
        limit:             gdrive.storage_quota.limit,
        total_usage:       gdrive.storage_quota.usage,
        drive_usage:       gdrive.storage_quota.usage_in_drive,
        drive_trash_usage: gdrive.storage_quota.usage_in_drive_trash
      )
    end
  end
