class AddGoogleFileIdToGoogleFilePermissions < ActiveRecord::Migration[7.0]
  def change
    execute "TRUNCATE TABLE google_file_permissions"
    add_column :google_file_permissions, :google_file_id, :string, null: false
  end
end
