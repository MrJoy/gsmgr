# frozen_string_literal: true

class AddGoogleFileIdToGoogleFilePermissions < ActiveRecord::Migration[7.0]
  def up
    execute "TRUNCATE TABLE google_file_permissions"
    add_column :google_file_permissions, :google_file_id, :string, null: false # rubocop:disable Rails/NotNullColumn
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
