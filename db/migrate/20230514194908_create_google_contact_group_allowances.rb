# frozen_string_literal: true

class CreateGoogleContactGroupAllowances < ActiveRecord::Migration[7.0]
  def change
    create_table :google_contact_group_allowances do |t|
      t.bigint :google_contact_group_id, null: false
      t.bigint :google_file_id,          null: false
      t.string :access_level,            null: false

      t.timestamps
    end
  end
end
