# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_09_04_012233) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "exercise_count_logs", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.integer "count", null: false
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_exercise_count_logs_on_created_at"
    t.index ["exercise_id"], name: "index_exercise_count_logs_on_exercise_id"
  end

  create_table "exercises", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_exercises_on_user_id"
  end

  create_table "items", id: :serial, force: :cascade do |t|
    t.integer "store_id", null: false
    t.string "name", null: false
    t.integer "needed", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_items_on_store_id"
  end

  create_table "pghero_query_stats", force: :cascade do |t|
    t.text "database"
    t.text "user"
    t.text "query"
    t.bigint "query_hash"
    t.float "total_time"
    t.bigint "calls"
    t.datetime "captured_at"
    t.index ["database", "captured_at"], name: "index_pghero_query_stats_on_database_and_captured_at"
  end

  create_table "pghero_space_stats", force: :cascade do |t|
    t.text "database"
    t.text "schema"
    t.text "relation"
    t.bigint "size"
    t.datetime "captured_at"
    t.index ["database", "captured_at"], name: "index_pghero_space_stats_on_database_and_captured_at"
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "user_id"
    t.string "url", null: false
    t.string "handler", null: false
    t.string "referer"
    t.jsonb "params"
    t.string "method", null: false
    t.string "format", null: false
    t.integer "status"
    t.integer "view"
    t.integer "db"
    t.string "ip", null: false
    t.string "user_agent"
    t.datetime "requested_at", null: false
    t.boolean "bot", default: false, null: false
    t.string "location"
    t.string "isp"
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
    t.index ["user_id"], name: "index_sms_records_on_user_id"
  end

  create_table "stores", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "viewed_at"
    t.index ["user_id"], name: "index_stores_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_activity_at"
    t.string "phone"
    t.float "sms_allowance", default: 1.0, null: false, comment: "Total cost in EUR of text messages that the user is allowed to accrue."
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "weight_logs", force: :cascade do |t|
    t.float "weight", null: false
    t.string "note"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "created_at"], name: "index_weight_logs_on_user_id_and_created_at"
  end

  add_foreign_key "exercise_count_logs", "exercises"
  add_foreign_key "exercises", "users"
  add_foreign_key "items", "stores"
  add_foreign_key "requests", "users"
  add_foreign_key "sms_records", "users"
  add_foreign_key "stores", "users"
  add_foreign_key "weight_logs", "users"
end
