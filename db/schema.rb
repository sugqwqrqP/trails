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

ActiveRecord::Schema[7.0].define(version: 2025_12_20_074310) do
  create_table "run_types", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "runs", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "run_number", null: false
    t.date "run_on", null: false
    t.boolean "is_up", null: false
    t.string "departure_station_name", null: false
    t.string "arrival_station_name", null: false
    t.time "departure_time", null: false
    t.time "arrival_time", null: false
  end

  create_table "sections", force: :cascade do |t|
    t.integer "run_type_id", null: false
    t.integer "from_station_id", null: false
    t.integer "to_station_id", null: false
    t.integer "section_order"
    t.integer "required_time"
    t.integer "fee"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_station_id"], name: "index_sections_on_from_station_id"
    t.index ["run_type_id"], name: "index_sections_on_run_type_id"
    t.index ["to_station_id"], name: "index_sections_on_to_station_id"
  end

  create_table "stations", force: :cascade do |t|
    t.string "station_name", null: false
    t.integer "station_order", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "login_id", null: false
    t.string "password_digest", null: false
    t.string "user_fullname", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "sections", "from_stations"
  add_foreign_key "sections", "run_types"
  add_foreign_key "sections", "to_stations"
end
