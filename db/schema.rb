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

ActiveRecord::Schema[7.0].define(version: 2023_06_11_195314) do
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
    t.bigint "storage_limit"
    t.bigint "storage_total_usage"
    t.bigint "storage_drive_usage"
    t.bigint "storage_drive_trash_usage"
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
    t.string "raw_email", null: false
    t.index "google_contact_id, lower((email)::text) varchar_pattern_ops", name: "idx_gce_on_google_contact_id_and_email", unique: true
    t.index "lower((email)::text) varchar_pattern_ops", name: "index_google_contact_emails_on_email"
  end

  create_table "google_contact_group_allowances", force: :cascade do |t|
    t.bigint "google_contact_group_id", null: false
    t.bigint "google_file_id", null: false
    t.string "access_level", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["google_contact_group_id", "google_file_id"], name: "idx_gcgas_on_group_and_file", unique: true
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

  create_table "google_file_permissions", force: :cascade do |t|
    t.bigint "google_account_id", null: false
    t.string "google_id", null: false
    t.string "role", null: false
    t.string "target_type", null: false
    t.string "email_address"
    t.boolean "deleted"
    t.boolean "pending_owner"
    t.boolean "allow_file_discovery"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "google_file_id", null: false
    t.index ["google_account_id", "google_file_id", "google_id"], name: "idx_google_file_permissions_on_account_file_and_id", unique: true
  end

  create_table "google_file_permissions_files", id: false, force: :cascade do |t|
    t.bigint "google_file_id", null: false
    t.bigint "google_file_permission_id", null: false
    t.index ["google_file_id", "google_file_permission_id"], name: "idx_gfp_files_on_file_id_and_permission_id", unique: true
    t.index ["google_file_permission_id"], name: "index_gfp_files_on_google_file_permission_id"
  end

  create_table "google_files", force: :cascade do |t|
    t.bigint "google_account_id", null: false
    t.string "google_id", null: false
    t.bigint "parent_id"
    t.string "name", null: false
    t.string "owner", null: false
    t.jsonb "capabilities", default: {}, null: false
    t.string "spaces", default: [], null: false, array: true
    t.string "web_view_link", null: false
    t.bigint "quota_size", null: false
    t.boolean "shared", null: false
    t.boolean "starred", null: false
    t.boolean "trashed", null: false
    t.jsonb "shortcut"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "mime_type", default: "", null: false
    t.index ["google_account_id", "google_id"], name: "index_google_files_on_google_account_id_and_google_id", unique: true
    t.index ["parent_id"], name: "index_google_files_on_parent_id"
  end

  create_table "google_tokens", force: :cascade do |t|
    t.string "google_id", null: false
    t.text "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["google_id"], name: "index_google_tokens_on_google_id", unique: true
  end

end
