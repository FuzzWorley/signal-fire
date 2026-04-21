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

ActiveRecord::Schema[8.1].define(version: 2026_04_21_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "anonymous_check_in_counts", force: :cascade do |t|
    t.integer "count", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_anonymous_check_in_counts_on_event_id", unique: true
  end

  create_table "check_ins", force: :cascade do |t|
    t.datetime "checked_in_at", null: false
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["event_id"], name: "index_check_ins_on_event_id"
    t.index ["user_id", "event_id"], name: "index_check_ins_on_user_id_and_event_id", unique: true
    t.index ["user_id"], name: "index_check_ins_on_user_id"
  end

  create_table "empty_totem_email_captures", force: :cascade do |t|
    t.datetime "captured_at", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.bigint "totem_id", null: false
    t.datetime "updated_at", null: false
    t.index ["totem_id"], name: "index_empty_totem_email_captures_on_totem_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "chat_platform", null: false
    t.string "chat_url", null: false
    t.text "community_norms"
    t.datetime "created_at", null: false
    t.boolean "created_by_admin", default: false, null: false
    t.text "description"
    t.datetime "end_time", null: false
    t.bigint "host_user_id", null: false
    t.string "recurrence_type", null: false
    t.string "slug", null: false
    t.datetime "start_time", null: false
    t.string "status", default: "active", null: false
    t.string "title", null: false
    t.bigint "totem_id", null: false
    t.datetime "updated_at", null: false
    t.index ["host_user_id"], name: "index_events_on_host_user_id"
    t.index ["slug"], name: "index_events_on_slug", unique: true
    t.index ["start_time"], name: "index_events_on_start_time"
    t.index ["status"], name: "index_events_on_status"
    t.index ["totem_id"], name: "index_events_on_totem_id"
  end

  create_table "host_profiles", force: :cascade do |t|
    t.text "blurb"
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "invitation_token"
    t.datetime "invitation_token_expires_at"
    t.datetime "invite_accepted_at"
    t.string "invite_status", default: "invited", null: false
    t.datetime "invited_at"
    t.string "timezone"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["invitation_token"], name: "index_host_profiles_on_invitation_token", unique: true
    t.index ["user_id"], name: "index_host_profiles_on_user_id", unique: true
  end

  create_table "host_subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "host_user_id", null: false
    t.boolean "notify_new_event", default: true, null: false
    t.boolean "notify_reminder", default: true, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "host_user_id"], name: "index_host_subscriptions_on_user_id_and_host_user_id", unique: true
  end

  create_table "host_totem_assignments", force: :cascade do |t|
    t.datetime "assigned_at"
    t.bigint "assigned_by_admin_id"
    t.datetime "created_at", null: false
    t.bigint "host_user_id", null: false
    t.bigint "totem_id", null: false
    t.datetime "updated_at", null: false
    t.index ["host_user_id", "totem_id"], name: "index_host_totem_assignments_on_host_user_id_and_totem_id", unique: true
    t.index ["host_user_id"], name: "index_host_totem_assignments_on_host_user_id"
    t.index ["totem_id"], name: "index_host_totem_assignments_on_totem_id"
  end

  create_table "notification_deliveries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.string "notification_type", null: false
    t.datetime "opened_at"
    t.datetime "sent_at"
    t.string "source_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["event_id"], name: "index_notification_deliveries_on_event_id"
    t.index ["user_id", "event_id", "notification_type"], name: "idx_on_user_id_event_id_notification_type_be0601ef91"
    t.index ["user_id"], name: "index_notification_deliveries_on_user_id"
  end

  create_table "totem_follows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "notify_new_event", default: true, null: false
    t.boolean "notify_reminder", default: true, null: false
    t.bigint "totem_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["totem_id"], name: "index_totem_follows_on_totem_id"
    t.index ["user_id", "totem_id"], name: "index_totem_follows_on_user_id_and_totem_id", unique: true
    t.index ["user_id"], name: "index_totem_follows_on_user_id"
  end

  create_table "totems", force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.string "location"
    t.string "name", null: false
    t.string "qr_url"
    t.string "slug", null: false
    t.string "sublocation"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_totems_on_active"
    t.index ["slug"], name: "index_totems_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "auth_method", default: "email", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "google_uid"
    t.boolean "is_admin", default: false, null: false
    t.boolean "is_host", default: false, null: false
    t.string "name"
    t.jsonb "notification_prefs", default: {"reminder" => true, "new_event" => true}, null: false
    t.string "password_digest"
    t.string "push_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["google_uid"], name: "index_users_on_google_uid", unique: true
  end

  add_foreign_key "anonymous_check_in_counts", "events"
  add_foreign_key "check_ins", "events"
  add_foreign_key "check_ins", "users"
  add_foreign_key "empty_totem_email_captures", "totems"
  add_foreign_key "events", "totems"
  add_foreign_key "events", "users", column: "host_user_id"
  add_foreign_key "host_profiles", "users"
  add_foreign_key "host_subscriptions", "users"
  add_foreign_key "host_subscriptions", "users", column: "host_user_id"
  add_foreign_key "host_totem_assignments", "totems"
  add_foreign_key "host_totem_assignments", "users", column: "assigned_by_admin_id"
  add_foreign_key "host_totem_assignments", "users", column: "host_user_id"
  add_foreign_key "notification_deliveries", "events"
  add_foreign_key "notification_deliveries", "users"
  add_foreign_key "totem_follows", "totems"
  add_foreign_key "totem_follows", "users"
end
