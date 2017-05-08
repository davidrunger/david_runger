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

ActiveRecord::Schema.define(version: 20170508052142) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "items", id: :serial, force: :cascade do |t|
    t.integer "store_id", null: false
    t.string "name", null: false
    t.integer "needed", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "archived", default: false, null: false
    t.index ["store_id"], name: "index_items_on_store_id"
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "user_id"
    t.string "url"
    t.string "handler"
    t.string "referer"
    t.jsonb "params"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "stores", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_stores_on_user_id"
  end

  create_table "templates", force: :cascade do |t|
    t.string "name"
    t.string "body"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_templates_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_activity_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "items", "stores"
  add_foreign_key "requests", "users"
  add_foreign_key "stores", "users"
  add_foreign_key "templates", "users"
end
