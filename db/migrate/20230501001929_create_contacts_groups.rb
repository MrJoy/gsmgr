# frozen_string_literal: true

class CreateContactsGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :google_contact_groups do |t|
      t.bigint :google_account_id, null: false
      t.string :google_id,         null: false

      t.string :name,           null: false
      t.string :formatted_name, null: false
      t.string :group_type,     null: false

      t.index "google_account_id, lower((google_id)::text) varchar_pattern_ops",
              name:   "index_gcg_on_google_account_id_and_google_id",
              unique: true

      t.timestamps
    end
  end
end
