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

ActiveRecord::Schema[8.0].define(version: 2025_10_23_123354) do
  create_table "deployments", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "project_id"
    t.string "service_id"
    t.string "docker_image"
    t.string "service_name"
    t.string "project_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_deployments_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "railway_api_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["railway_api_key"], name: "index_users_on_railway_api_key", unique: true
  end

  add_foreign_key "deployments", "users"
end
