# frozen_string_literal: true

class AddUniqueConstraintOnGoogleContactGroupAllowances < ActiveRecord::Migration[7.0]
  def change
    add_index :google_contact_group_allowances, %i[google_contact_group_id google_file_id], unique: true, name: "idx_gcgas_on_group_and_file"
  end
end
