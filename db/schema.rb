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

ActiveRecord::Schema[7.0].define(version: 2026_01_06_181739) do
  create_table "car_types", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cars", force: :cascade do |t|
    t.integer "run_id", null: false
    t.integer "car_type_id", null: false
    t.integer "number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["car_type_id"], name: "index_cars_on_car_type_id"
    t.index ["run_id", "number"], name: "index_cars_on_run_id_and_number", unique: true
    t.index ["run_id"], name: "index_cars_on_run_id"
  end

  create_table "reservation_seats", force: :cascade do |t|
    t.integer "reservation_id", null: false
    t.integer "seat_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reservation_id"], name: "index_reservation_seats_on_reservation_id"
    t.index ["seat_id"], name: "index_reservation_seats_on_seat_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "run_id", null: false
    t.integer "departure_station_id", null: false
    t.integer "arrival_station_id", null: false
    t.string "holder_name", null: false
    t.boolean "is_issued", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arrival_station_id"], name: "index_reservations_on_arrival_station_id"
    t.index ["departure_station_id"], name: "index_reservations_on_departure_station_id"
    t.index ["run_id"], name: "index_reservations_on_run_id"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "run_types", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "runs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "run_number", null: false
    t.date "run_on", null: false
    t.boolean "is_up", null: false
    t.time "first_station_departure_time", null: false
    t.integer "run_type_id", null: false
    t.index ["run_type_id"], name: "index_runs_on_run_type_id"
  end

  create_table "seats", force: :cascade do |t|
    t.integer "car_id", null: false
    t.integer "row", null: false
    t.string "column", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["car_id", "row", "column"], name: "index_seats_on_car_id_and_row_and_column", unique: true
    t.index ["car_id"], name: "index_seats_on_car_id"
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

  add_foreign_key "cars", "car_types"
  add_foreign_key "cars", "runs"
  add_foreign_key "reservation_seats", "reservations"
  add_foreign_key "reservation_seats", "seats"
  add_foreign_key "reservations", "runs"
  add_foreign_key "reservations", "stations", column: "arrival_station_id"
  add_foreign_key "reservations", "stations", column: "departure_station_id"
  add_foreign_key "reservations", "users"
  add_foreign_key "runs", "run_types"
  add_foreign_key "seats", "cars"
  add_foreign_key "sections", "run_types"
  add_foreign_key "sections", "stations", column: "from_station_id"
  add_foreign_key "sections", "stations", column: "to_station_id"
end
