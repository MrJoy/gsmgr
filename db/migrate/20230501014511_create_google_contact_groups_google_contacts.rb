# frozen_string_literal: true

class CreateGoogleContactGroupsGoogleContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :google_contact_groups_contacts, id: false do |t|
      t.bigint :google_contact_group_id, null: false
      t.bigint :google_contact_id,       null: false
      t.index %i[google_contact_group_id google_contact_id],
              name:   "idx_gcg_gc_on_gcg_id_and_gc_id",
              unique: true
      t.index :google_contact_id, name: "idx_gcg_gc_on_gc_id"
    end
  end
end
