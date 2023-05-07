# frozen_string_literal: true

# Update an account with the latest Google Drive info.
class GoogleDriveInfoSync
  prepend SimpleCommand
  include CommandHelper

  def initialize(account_id)
    @account_id = account_id
  end

  def call
    account, client = account_and_client(@account_id)

    return if account.blank?

    info = client.fetch_drive_info
    account.update!(
      storage_limit:             info.limit,
      storage_total_usage:       info.total_usage,
      storage_drive_usage:       info.drive_usage,
      storage_drive_trash_usage: info.drive_trash_usage
    )
  end
end
