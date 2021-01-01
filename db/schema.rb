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

ActiveRecord::Schema.define(version: 2021_01_03_111241) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_mailbox_inbound_emails", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.string "message_id", null: false
    t.string "message_checksum", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
  end

  create_table "auth_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "secret", null: false
    t.text "name"
    t.datetime "last_used_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["secret"], name: "index_auth_tokens_on_secret"
    t.index ["user_id", "secret"], name: "index_auth_tokens_on_user_id_and_secret", unique: true
  end

  create_table "ip_blocks", force: :cascade do |t|
    t.text "ip", null: false
    t.text "reason"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ip"], name: "index_ip_blocks_on_ip", unique: true
  end

  create_table "items", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "name", null: false
    t.integer "needed", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_items_on_store_id"
  end

  create_table "log_shares", force: :cascade do |t|
    t.bigint "log_id", null: false
    t.text "email", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["log_id", "email"], name: "index_log_shares_on_log_id_and_email", unique: true
  end

  create_table "logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.string "slug", null: false
    t.string "data_label", null: false
    t.string "data_type", null: false
    t.boolean "publicly_viewable", default: false, null: false
    t.integer "reminder_time_in_seconds", comment: "Time in seconds, which, if elapsed since the creation of log or most recent log entry (whichever is later) will trigger a reminder to be sent (via email) to the owning user."
    t.datetime "reminder_last_sent_at"
    t.index ["user_id", "name"], name: "index_logs_on_user_id_and_name", unique: true
    t.index ["user_id", "slug"], name: "index_logs_on_user_id_and_slug", unique: true
  end

  create_table "number_log_entries", force: :cascade do |t|
    t.bigint "log_id", null: false
    t.float "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "note"
    t.index ["log_id"], name: "index_number_log_entries_on_log_id"
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "user_id"
    t.string "url", null: false
    t.string "handler", null: false
    t.string "referer"
    t.jsonb "params"
    t.string "method", null: false
    t.string "format"
    t.integer "status", null: false
    t.integer "view"
    t.integer "db"
    t.string "ip", null: false
    t.string "user_agent"
    t.datetime "requested_at", null: false
    t.string "location"
    t.string "isp"
    t.string "request_id", null: false
    t.bigint "auth_token_id"
    t.bigint "admin_user_id"
    t.index ["admin_user_id"], name: "index_requests_on_admin_user_id"
    t.index ["auth_token_id"], name: "index_requests_on_auth_token_id"
    t.index ["isp"], name: "index_requests_on_isp"
    t.index ["request_id"], name: "index_requests_on_request_id", unique: true
    t.index ["requested_at"], name: "index_requests_on_requested_at"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "sms_records", comment: "Records of SMS messages sent via Nexmo", force: :cascade do |t|
    t.string "nexmo_id", null: false, comment: "The message id provided by Nexmo"
    t.string "status", null: false, comment: "The status code provided by Nexmo"
    t.string "error", comment: "Error description, provided by Nexmo, if present"
    t.string "to", null: false, comment: "The phone number to which the message was sent"
    t.float "cost", comment: "Cost of the message in EUR; may be NULL if send failed"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nexmo_id"], name: "index_sms_records_on_nexmo_id", unique: true
    t.index ["user_id"], name: "index_sms_records_on_user_id"
  end

  create_table "stores", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "viewed_at"
    t.text "notes"
    t.index ["user_id"], name: "index_stores_on_user_id"
  end

  create_table "text_log_entries", force: :cascade do |t|
    t.bigint "log_id", null: false
    t.text "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "note"
    t.index ["log_id"], name: "index_text_log_entries_on_log_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
    t.float "sms_allowance", default: 1.0, null: false, comment: "Total cost in EUR of text messages that the user is allowed to accrue."
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "workouts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "time_in_seconds", null: false
    t.jsonb "rep_totals", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "publicly_viewable", default: false, null: false
    t.index ["created_at"], name: "index_workouts_on_created_at"
    t.index ["user_id"], name: "index_workouts_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "auth_tokens", "users"
  add_foreign_key "items", "stores"
  add_foreign_key "log_shares", "logs"
  add_foreign_key "logs", "users"
  add_foreign_key "number_log_entries", "logs"
  add_foreign_key "requests", "admin_users"
  add_foreign_key "requests", "auth_tokens"
  add_foreign_key "requests", "users"
  add_foreign_key "sms_records", "users"
  add_foreign_key "stores", "users"
  add_foreign_key "text_log_entries", "logs"
  add_foreign_key "workouts", "users"
end
