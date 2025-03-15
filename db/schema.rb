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

ActiveRecord::Schema[8.0].define(version: 2025_03_15_194328) do
  create_schema "pghero"

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"

  create_table "action_mailbox_inbound_emails", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.string "message_id", null: false
    t.string "message_checksum", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
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
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
  end

  create_table "auth_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "secret", null: false
    t.text "name"
    t.datetime "last_used_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["secret"], name: "index_auth_tokens_on_secret"
    t.index ["user_id", "secret"], name: "index_auth_tokens_on_user_id_and_secret", unique: true
  end

  create_table "banned_path_fragments", force: :cascade do |t|
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["value"], name: "index_banned_path_fragments_on_value", unique: true
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "query_id"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.bigint "creator_id"
    t.bigint "query_id"
    t.string "state"
    t.string "schedule"
    t.text "emails"
    t.text "slack_channels"
    t.string "check_type"
    t.text "message"
    t.datetime "last_run_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.bigint "dashboard_id"
    t.bigint "query_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.text "description"
    t.text "statement"
    t.string "data_source"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "check_in_submissions", force: :cascade do |t|
    t.bigint "check_in_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["check_in_id", "user_id"], name: "index_check_in_submissions_on_check_in_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_check_in_submissions_on_user_id"
  end

  create_table "check_ins", force: :cascade do |t|
    t.bigint "marriage_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["marriage_id"], name: "index_check_ins_on_marriage_id"
  end

  create_table "ci_step_results", force: :cascade do |t|
    t.string "name", null: false
    t.float "seconds", null: false
    t.datetime "started_at", null: false
    t.datetime "stopped_at", null: false
    t.boolean "passed", default: false, null: false
    t.bigint "github_run_id", null: false
    t.integer "github_run_attempt", null: false
    t.string "branch", null: false
    t.string "sha", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["name", "github_run_id", "github_run_attempt"], name: "idx_on_name_github_run_id_github_run_attempt_96ff2b0b91", unique: true
    t.index ["user_id"], name: "index_ci_step_results_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string "path", null: false
    t.text "content", null: false
    t.bigint "user_id"
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["path"], name: "index_comments_on_path"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "csp_reports", force: :cascade do |t|
    t.string "document_uri", null: false
    t.string "violated_directive", null: false
    t.string "original_policy", null: false
    t.string "ip", null: false
    t.string "referrer"
    t.string "blocked_uri"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "user_agent", null: false
  end

  create_table "datamigration_runs", force: :cascade do |t|
    t.string "name", null: false
    t.string "developer", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["developer"], name: "index_datamigration_runs_on_developer"
    t.index ["name"], name: "index_datamigration_runs_on_name"
  end

  create_table "deploys", force: :cascade do |t|
    t.string "git_sha", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["git_sha"], name: "index_deploys_on_git_sha"
  end

  create_table "emotional_needs", force: :cascade do |t|
    t.bigint "marriage_id", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["marriage_id", "name"], name: "index_emotional_needs_on_marriage_id_and_name", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "type", null: false
    t.bigint "user_id"
    t.bigint "admin_user_id"
    t.jsonb "data"
    t.string "ip"
    t.string "isp"
    t.string "location"
    t.string "stack_trace", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "user_agent"
    t.index ["admin_user_id"], name: "index_events_on_admin_user_id"
    t.index ["ip"], name: "index_events_on_ip"
    t.index ["type"], name: "index_events_on_type"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "ip_blocks", force: :cascade do |t|
    t.string "ip", null: false
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "isp"
    t.string "location"
    t.index ["ip"], name: "index_ip_blocks_on_ip", unique: true
  end

  create_table "items", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.string "name", null: false
    t.integer "needed", default: 1, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["store_id", "name"], name: "index_items_on_store_id_and_name", unique: true
  end

  create_table "json_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "preference_type", null: false
    t.jsonb "json", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "preference_type"], name: "index_json_preferences_on_user_id_and_preference_type", unique: true
  end

  create_table "log_entries", force: :cascade do |t|
    t.bigint "log_id", null: false
    t.string "log_entry_datum_type", null: false
    t.bigint "log_entry_datum_id", null: false
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["log_entry_datum_type", "log_entry_datum_id"], name: "idx_on_log_entry_datum_type_log_entry_datum_id_e43ce914c3", unique: true
    t.index ["log_id"], name: "index_log_entries_on_log_id"
  end

  create_table "log_shares", force: :cascade do |t|
    t.bigint "log_id", null: false
    t.text "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["log_id", "email"], name: "index_log_shares_on_log_id_and_email", unique: true
  end

  create_table "logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "description"
    t.string "slug", null: false
    t.string "data_label", null: false
    t.string "data_type", null: false
    t.boolean "publicly_viewable", default: false, null: false
    t.integer "reminder_time_in_seconds", comment: "Time in seconds, which, if elapsed since the creation of log or most recent log entry (whichever is later) will trigger a reminder to be sent (via email) to the owning user."
    t.datetime "reminder_last_sent_at", precision: nil
    t.index ["user_id", "name"], name: "index_logs_on_user_id_and_name", unique: true
    t.index ["user_id", "slug"], name: "index_logs_on_user_id_and_slug", unique: true
  end

  create_table "marriage_memberships", force: :cascade do |t|
    t.bigint "marriage_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["marriage_id"], name: "index_marriage_memberships_on_marriage_id"
    t.index ["user_id"], name: "index_marriage_memberships_on_user_id", unique: true
  end

  create_table "marriages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "need_satisfaction_ratings", force: :cascade do |t|
    t.bigint "emotional_need_id", null: false
    t.bigint "user_id", null: false
    t.bigint "check_in_id", null: false
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["check_in_id"], name: "index_need_satisfaction_ratings_on_check_in_id"
    t.index ["emotional_need_id"], name: "index_need_satisfaction_ratings_on_emotional_need_id"
    t.index ["user_id"], name: "index_need_satisfaction_ratings_on_user_id"
  end

  create_table "number_log_entry_data", force: :cascade do |t|
    t.float "data", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "pghero_query_stats", force: :cascade do |t|
    t.text "database"
    t.text "user"
    t.text "query"
    t.bigint "query_hash"
    t.float "total_time"
    t.bigint "calls"
    t.datetime "captured_at", precision: nil
    t.index ["database", "captured_at"], name: "index_pghero_query_stats_on_database_and_captured_at"
  end

  create_table "pghero_space_stats", force: :cascade do |t|
    t.text "database"
    t.text "schema"
    t.text "relation"
    t.bigint "size"
    t.datetime "captured_at", precision: nil
    t.index ["database", "captured_at"], name: "index_pghero_space_stats_on_database_and_captured_at"
  end

  create_table "quiz_participations", force: :cascade do |t|
    t.bigint "quiz_id", null: false
    t.bigint "participant_id", null: false
    t.string "display_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["participant_id"], name: "index_quiz_participations_on_participant_id"
    t.index ["quiz_id", "display_name"], name: "index_quiz_participations_on_quiz_id_and_display_name", unique: true
    t.index ["quiz_id", "participant_id"], name: "index_quiz_participations_on_quiz_id_and_participant_id", unique: true
  end

  create_table "quiz_question_answer_selections", force: :cascade do |t|
    t.bigint "answer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "participation_id", null: false
    t.index ["answer_id"], name: "index_quiz_question_answer_selections_on_answer_id"
    t.index ["participation_id"], name: "index_quiz_question_answer_selections_on_participation_id"
  end

  create_table "quiz_question_answers", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.text "content", null: false
    t.boolean "is_correct", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_quiz_question_answers_on_question_id"
  end

  create_table "quiz_questions", force: :cascade do |t|
    t.bigint "quiz_id", null: false
    t.text "content", null: false
    t.string "status", default: "open", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_quiz_questions_on_quiz_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.string "name"
    t.bigint "owner_id", null: false
    t.string "status", default: "unstarted", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_question_number", default: 1, null: false
    t.index ["owner_id"], name: "index_quizzes_on_owner_id"
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
    t.datetime "requested_at", precision: nil, null: false
    t.string "location"
    t.string "isp"
    t.string "request_id", null: false
    t.bigint "auth_token_id"
    t.bigint "admin_user_id"
    t.integer "total"
    t.index ["admin_user_id"], name: "index_requests_on_admin_user_id"
    t.index ["auth_token_id"], name: "index_requests_on_auth_token_id"
    t.index ["handler"], name: "index_requests_on_handler"
    t.index ["ip"], name: "index_requests_on_ip"
    t.index ["request_id"], name: "index_requests_on_request_id", unique: true
    t.index ["requested_at"], name: "index_requests_on_requested_at"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "stores", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "viewed_at", precision: nil, null: false
    t.text "notes"
    t.boolean "private", default: false, null: false
    t.index ["user_id", "name"], name: "index_stores_on_user_id_and_name", unique: true
  end

  create_table "text_log_entry_data", force: :cascade do |t|
    t.text "data", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "timeseries", force: :cascade do |t|
    t.text "name", null: false
    t.jsonb "measurements", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "google_sub"
    t.string "public_name"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.jsonb "object"
    t.jsonb "object_changes"
    t.datetime "created_at", null: false
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "workouts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "time_in_seconds", null: false
    t.jsonb "rep_totals", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "publicly_viewable", default: false, null: false
    t.index ["created_at"], name: "index_workouts_on_created_at"
    t.index ["user_id"], name: "index_workouts_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "auth_tokens", "users"
  add_foreign_key "blazer_audits", "admin_users", column: "user_id"
  add_foreign_key "blazer_audits", "blazer_queries", column: "query_id"
  add_foreign_key "blazer_checks", "admin_users", column: "creator_id"
  add_foreign_key "blazer_checks", "blazer_queries", column: "query_id"
  add_foreign_key "blazer_dashboard_queries", "blazer_dashboards", column: "dashboard_id"
  add_foreign_key "blazer_dashboard_queries", "blazer_queries", column: "query_id"
  add_foreign_key "blazer_dashboards", "admin_users", column: "creator_id"
  add_foreign_key "blazer_queries", "admin_users", column: "creator_id"
  add_foreign_key "check_in_submissions", "check_ins"
  add_foreign_key "check_in_submissions", "users"
  add_foreign_key "check_ins", "marriages"
  add_foreign_key "ci_step_results", "users"
  add_foreign_key "comments", "comments", column: "parent_id"
  add_foreign_key "comments", "users", on_delete: :nullify
  add_foreign_key "emotional_needs", "marriages"
  add_foreign_key "events", "admin_users"
  add_foreign_key "events", "users"
  add_foreign_key "items", "stores"
  add_foreign_key "json_preferences", "users"
  add_foreign_key "log_entries", "logs"
  add_foreign_key "log_shares", "logs"
  add_foreign_key "logs", "users"
  add_foreign_key "marriage_memberships", "marriages"
  add_foreign_key "marriage_memberships", "users"
  add_foreign_key "need_satisfaction_ratings", "check_ins"
  add_foreign_key "need_satisfaction_ratings", "emotional_needs"
  add_foreign_key "need_satisfaction_ratings", "users"
  add_foreign_key "quiz_participations", "quizzes"
  add_foreign_key "quiz_participations", "users", column: "participant_id"
  add_foreign_key "quiz_question_answer_selections", "quiz_participations", column: "participation_id"
  add_foreign_key "quiz_question_answer_selections", "quiz_question_answers", column: "answer_id"
  add_foreign_key "quiz_question_answers", "quiz_questions", column: "question_id"
  add_foreign_key "quiz_questions", "quizzes"
  add_foreign_key "quizzes", "users", column: "owner_id"
  add_foreign_key "requests", "admin_users"
  add_foreign_key "requests", "auth_tokens", on_delete: :nullify
  add_foreign_key "requests", "users"
  add_foreign_key "stores", "users"
  add_foreign_key "workouts", "users"
end
