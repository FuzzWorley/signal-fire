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

ActiveRecord::Schema[8.1].define(version: 2026_04_16_000010) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "attendances", force: :cascade do |t|
    t.string "category"
    t.datetime "checked_in_at", null: false
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.bigint "host_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["event_id"], name: "index_attendances_on_event_id"
    t.index ["host_id"], name: "index_attendances_on_host_id"
    t.index ["user_id", "event_id"], name: "index_attendances_on_user_id_and_event_id", unique: true
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "activity_type"
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "extended_until"
    t.bigint "host_id", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.string "location_name"
    t.decimal "longitude", precision: 10, scale: 6
    t.string "recurrence_rule"
    t.integer "scheduled_duration_min", default: 90, null: false
    t.datetime "start_time", null: false
    t.string "status", default: "draft", null: false
    t.string "title", default: "", null: false
    t.bigint "totem_page_id"
    t.datetime "updated_at", null: false
    t.index ["host_id"], name: "index_events_on_host_id"
    t.index ["start_time"], name: "index_events_on_start_time"
    t.index ["status"], name: "index_events_on_status"
    t.index ["totem_page_id"], name: "index_events_on_totem_page_id"
  end

  create_table "hosts", force: :cascade do |t|
    t.text "application_notes"
    t.datetime "approved_at"
    t.bigint "approved_by_admin_id"
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "name", default: "", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["approved_by_admin_id"], name: "index_hosts_on_approved_by_admin_id"
    t.index ["user_id"], name: "index_hosts_on_user_id", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.bigint "host_id", null: false
    t.datetime "send_at", null: false
    t.datetime "sent_at"
    t.jsonb "sent_to_user_ids", default: [], null: false
    t.string "status", default: "scheduled", null: false
    t.string "tier", default: "following", null: false
    t.string "title", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_notifications_on_event_id"
    t.index ["host_id"], name: "index_notifications_on_host_id"
    t.index ["send_at"], name: "index_notifications_on_send_at"
    t.index ["status"], name: "index_notifications_on_status"
  end

  create_table "phone_verifications", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "phone_number", null: false
    t.datetime "updated_at", null: false
    t.datetime "verified_at"
    t.index ["phone_number", "code"], name: "index_phone_verifications_on_phone_number_and_code"
    t.index ["phone_number"], name: "index_phone_verifications_on_phone_number"
  end

  create_table "push_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "platform", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["token"], name: "index_push_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_push_tokens_on_user_id"
  end

  create_table "reputations", force: :cascade do |t|
    t.jsonb "by_category", default: {}, null: false
    t.datetime "created_at", null: false
    t.bigint "host_id", null: false
    t.integer "total_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["host_id"], name: "index_reputations_on_host_id"
    t.index ["user_id", "host_id"], name: "index_reputations_on_user_id_and_host_id", unique: true
    t.index ["user_id"], name: "index_reputations_on_user_id"
  end

  create_table "story_cards", force: :cascade do |t|
    t.string "card_type", null: false
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.string "generated_image_url"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "card_type"], name: "index_story_cards_on_event_id_and_card_type", unique: true
    t.index ["event_id"], name: "index_story_cards_on_event_id"
  end

  create_table "totem_pages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "group_name", default: "", null: false
    t.bigint "host_id", null: false
    t.text "norms_text"
    t.boolean "published", default: false, null: false
    t.string "qr_code_url"
    t.text "schedule_text"
    t.string "signal_link"
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.string "whatsapp_link"
    t.index ["host_id"], name: "index_totem_pages_on_host_id"
    t.index ["published"], name: "index_totem_pages_on_published"
    t.index ["slug"], name: "index_totem_pages_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "google_uid"
    t.string "host_status", default: "none", null: false
    t.jsonb "interests", default: {}, null: false
    t.string "name"
    t.jsonb "notification_prefs", default: {"discover" => true, "following" => true}, null: false
    t.string "phone_number"
    t.integer "radius_km", default: 10, null: false
    t.string "role", default: "attendee", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["google_uid"], name: "index_users_on_google_uid", unique: true
    t.index ["host_status"], name: "index_users_on_host_status"
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
  end

  add_foreign_key "attendances", "events"
  add_foreign_key "attendances", "hosts"
  add_foreign_key "attendances", "users"
  add_foreign_key "events", "hosts"
  add_foreign_key "events", "totem_pages"
  add_foreign_key "hosts", "users"
  add_foreign_key "hosts", "users", column: "approved_by_admin_id"
  add_foreign_key "notifications", "events"
  add_foreign_key "notifications", "hosts"
  add_foreign_key "push_tokens", "users"
  add_foreign_key "reputations", "hosts"
  add_foreign_key "reputations", "users"
  add_foreign_key "story_cards", "events"
  add_foreign_key "totem_pages", "hosts"
end
