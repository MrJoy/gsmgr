# frozen_string_literal: true

class SetUpCoreSchema < ActiveRecord::Migration[7.0]
  def change
    create_table "google_accounts", force: :cascade do |t|
      t.string "google_id", null: false
      t.string "email", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "scopes", default: [], array: true
      t.string "contact_sync_token"
      t.index "lower((email)::text) varchar_pattern_ops", name: "index_google_accounts_on_email"
      t.index "lower((google_id)::text) varchar_pattern_ops", name: "unique_google_accounts_idx", unique: true
    end

    create_table "google_calendar_instances", force: :cascade do |t|
      t.bigint "google_account_id", null: false
      t.bigint "google_calendar_id", null: false
      t.boolean "primary", null: false
      t.string "access_role", null: false
      t.string "summary", default: "", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index %w[google_account_id google_calendar_id], name: "idx_gcal_instances_on_google_account_id_and_google_calendar_id", unique: true
    end

    create_table "google_calendars", force: :cascade do |t|
      t.string "google_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index "lower((google_id)::text) varchar_pattern_ops", name: "unique_google_calendars_idx", unique: true
    end

    create_table "google_contact_emails", force: :cascade do |t|
      t.bigint "google_contact_id", null: false
      t.string "email", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index "google_contact_id, lower((email)::text) varchar_pattern_ops", name: "idx_gce_on_google_contact_id_and_email", unique: true
      t.index "lower((email)::text) varchar_pattern_ops", name: "index_google_contact_emails_on_email"
    end

    create_table "google_contacts", force: :cascade do |t|
      t.bigint "google_account_id", null: false
      t.string "google_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "primary_email"
      t.string "display_name"
      t.string "display_name_last_first"
      t.string "family_name"
      t.string "middle_name"
      t.string "given_name"
      t.index "google_account_id, lower((google_id)::text) varchar_pattern_ops", name: "index_google_contacts_on_google_account_id_and_google_id", unique: true
    end

    create_table "google_tokens", force: :cascade do |t|
      t.string "google_id", null: false
      t.text "token", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index :google_id, unique: true
    end
  end
end
