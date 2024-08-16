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

ActiveRecord::Schema[7.2].define(version: 2024_08_16_042624) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "caves", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "locatable_type", null: false
    t.bigint "locatable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locatable_type", "locatable_id"], name: "index_locations_on_locatable"
  end

  create_table "log_cave_copies", force: :cascade do |t|
    t.bigint "log_id", null: false
    t.bigint "cave_id"
    t.string "cave_title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cave_id"], name: "index_log_cave_copies_on_cave_id"
    t.index ["log_id"], name: "index_log_cave_copies_on_log_id"
  end

  create_table "log_location_copies", force: :cascade do |t|
    t.bigint "log_id", null: false
    t.bigint "location_id"
    t.string "location_title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_log_location_copies_on_location_id"
    t.index ["log_id"], name: "index_log_location_copies_on_log_id"
  end

  create_table "logs", force: :cascade do |t|
    t.text "personal_comments"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group_size"
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.index ["user_id"], name: "index_logs_on_user_id"
  end

  create_table "subsystems", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.bigint "cave_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cave_id"], name: "index_subsystems_on_cave_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", default: "caver", null: false
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "log_cave_copies", "caves"
  add_foreign_key "log_cave_copies", "logs"
  add_foreign_key "log_location_copies", "locations"
  add_foreign_key "log_location_copies", "logs"
  add_foreign_key "logs", "users"
  add_foreign_key "subsystems", "caves"
end
