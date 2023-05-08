# frozen_string_literal: true

class CreateGoogleFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :google_files do |t|
      t.bigint :google_account_id, null: false
      t.string :google_id,         null: false

      t.bigint  :parent_id
      t.string  :name,          null: false
      t.string  :owner,         null: false
      t.jsonb   :capabilities,  null: false, default: {}
      t.string  :spaces,        null: false, default: [], array: true
      t.string  :web_view_link, null: false
      t.bigint  :quota_size,    null: false
      t.boolean :shared,        null: false
      t.boolean :stared,        null: false
      t.boolean :trashed,       null: false
      t.jsonb   :shortcut

      t.timestamps

      t.index %i[google_account_id google_id], unique: true
      t.index :parent_id
    end

    create_table :google_file_permissions do |t|
      t.bigint :google_account_id, null: false
      t.string :google_id,         null: false

      t.string  :role,        null: false
      t.string  :target_type, null: false
      t.string  :email_address
      t.boolean :deleted
      t.boolean :pending_owner
      t.boolean :allow_file_discovery

      t.timestamps

      t.index %i[google_account_id google_id],
              unique: true,
              name:   "idx_google_file_permissions_on_google_account_id_and_google_id"
    end

    create_table "google_file_permissions_files", id: false, force: :cascade do |t|
      t.bigint "google_file_id", null: false
      t.bigint "google_file_permission_id", null: false
      t.index %w[google_file_id google_file_permission_id],
              name:   "idx_gfp_files_on_file_id_and_permission_id",
              unique: true
      t.index ["google_file_permission_id"], name: "index_gfp_files_on_google_file_permission_id"
    end
  end
end
