# frozen_string_literal: true

# rubocop:disable Rails/BulkChangeTable
class AddStorageInfoToGoogleAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :google_accounts, :storage_limit, :bigint
    add_column :google_accounts, :storage_total_usage, :bigint
    add_column :google_accounts, :storage_drive_usage, :bigint
    add_column :google_accounts, :storage_drive_trash_usage, :bigint
  end
end
# rubocop:enable Rails/BulkChangeTable
