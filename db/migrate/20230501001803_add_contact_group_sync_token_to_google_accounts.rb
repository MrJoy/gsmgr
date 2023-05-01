# frozen_string_literal: true

class AddContactGroupSyncTokenToGoogleAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :google_accounts, :contact_group_sync_token, :string
  end
end
