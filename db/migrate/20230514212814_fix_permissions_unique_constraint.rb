# frozen_string_literal: true

class FixPermissionsUniqueConstraint < ActiveRecord::Migration[7.0]
  def up
    remove_index :google_file_permissions,
                 name: :idx_google_file_permissions_on_google_account_id_and_google_id
    add_index :google_file_permissions,
              %i[google_account_id google_file_id google_id],
              unique: true,
              name:   :idx_google_file_permissions_on_account_file_and_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
