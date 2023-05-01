# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_05_01_014511) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "google_accounts", force: :cascade do |t|
    t.string "google_id", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "scopes", default: [], array: true
    t.string "contact_sync_token"
    t.string "contact_group_sync_token"
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
    t.index ["google_account_id", "google_calendar_id"], name: "idx_gcal_instances_on_google_account_id_and_google_calendar_id", unique: true
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

  create_table "google_contact_groups", force: :cascade do |t|
    t.bigint "google_account_id", null: false
    t.string "google_id", null: false
    t.string "name", null: false
    t.string "formatted_name", null: false
    t.string "group_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "google_account_id, lower((google_id)::text) varchar_pattern_ops", name: "index_gcg_on_google_account_id_and_google_id", unique: true
  end

  create_table "google_contact_groups_contacts", id: false, force: :cascade do |t|
    t.bigint "google_contact_group_id", null: false
    t.bigint "google_contact_id", null: false
    t.index ["google_contact_group_id", "google_contact_id"], name: "idx_gcg_gc_on_gcg_id_and_gc_id", unique: true
    t.index ["google_contact_id"], name: "idx_gcg_gc_on_gc_id"
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
    t.index ["google_id"], name: "index_google_tokens_on_google_id", unique: true
  end

end
