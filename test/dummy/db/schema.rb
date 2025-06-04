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

ActiveRecord::Schema[8.0].define(version: 2025_05_30_114142) do
  create_table "store_records", force: :cascade do |t|
    t.integer "structured_store_versioned_schema_id", null: false
    t.json "store"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["structured_store_versioned_schema_id"], name: "index_ss_records_on_versioned_schema_id"
  end

  create_table "structured_store_versioned_schemas", force: :cascade do |t|
    t.string "name", null: false
    t.string "version", null: false
    t.json "json_schema"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "version"], name: "index_structured_store_versioned_schemas_on_name_and_version", unique: true
  end

  add_foreign_key "store_records", "structured_store_versioned_schemas"
end
