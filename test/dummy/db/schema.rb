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

ActiveRecord::Schema[7.2].define(version: 2025_07_09_170437) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "binary_json_store_records", force: :cascade do |t|
    t.bigint "structured_store_store_versioned_schema_id", null: false
    t.jsonb "store"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["structured_store_store_versioned_schema_id"], name: "idx_on_structured_store_store_versioned_schema_id_c8a18b12fa"
  end

  create_table "binary_store_records", force: :cascade do |t|
    t.bigint "structured_store_store_versioned_schema_id", null: false
    t.binary "store"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["structured_store_store_versioned_schema_id"], name: "idx_on_structured_store_store_versioned_schema_id_1c22ed32c1"
  end

  create_table "custom_foreign_key_records", force: :cascade do |t|
    t.string "name"
    t.json "preferences"
    t.bigint "my_custom_schemaid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["my_custom_schemaid"], name: "index_custom_foreign_key_records_on_my_custom_schemaid"
  end

  create_table "depot_records", force: :cascade do |t|
    t.string "name"
    t.json "depot"
    t.bigint "structured_store_depot_versioned_schema_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["structured_store_depot_versioned_schema_id"], name: "idx_on_structured_store_depot_versioned_schema_id_d9851a2043"
  end

  create_table "example_records", force: :cascade do |t|
    t.string "name"
    t.json "store"
    t.json "metadata"
    t.json "settings"
    t.bigint "structured_store_store_versioned_schema_id", null: false
    t.bigint "structured_store_metadata_schema_id", null: false
    t.bigint "structured_store_settings_versioned_schema_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["structured_store_metadata_schema_id"], name: "index_example_records_on_structured_store_metadata_schema_id"
    t.index ["structured_store_settings_versioned_schema_id"], name: "idx_on_structured_store_settings_versioned_schema_i_c43f71aabb"
    t.index ["structured_store_store_versioned_schema_id"], name: "idx_on_structured_store_store_versioned_schema_id_f85a08fb17"
  end

  create_table "store_records", force: :cascade do |t|
    t.bigint "structured_store_store_versioned_schema_id", null: false
    t.json "store"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["structured_store_store_versioned_schema_id"], name: "idx_on_structured_store_store_versioned_schema_id_efc7fe1562"
  end

  create_table "structured_store_versioned_schemas", force: :cascade do |t|
    t.string "name", null: false
    t.string "version", null: false
    t.json "json_schema"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "version"], name: "index_structured_store_versioned_schemas_on_name_and_version", unique: true
  end

  create_table "text_store_records", force: :cascade do |t|
    t.bigint "structured_store_store_versioned_schema_id", null: false
    t.text "store"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["structured_store_store_versioned_schema_id"], name: "idx_on_structured_store_store_versioned_schema_id_38f195cecc"
  end

  create_table "warehouse_records", force: :cascade do |t|
    t.string "name"
    t.json "inventory"
    t.bigint "structured_store_warehouse_schema_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["structured_store_warehouse_schema_id"], name: "idx_on_structured_store_warehouse_schema_id_78d0cbf551"
  end

  add_foreign_key "binary_json_store_records", "structured_store_versioned_schemas", column: "structured_store_store_versioned_schema_id"
  add_foreign_key "binary_store_records", "structured_store_versioned_schemas", column: "structured_store_store_versioned_schema_id"
  add_foreign_key "custom_foreign_key_records", "structured_store_versioned_schemas", column: "my_custom_schemaid"
  add_foreign_key "depot_records", "structured_store_versioned_schemas", column: "structured_store_depot_versioned_schema_id"
  add_foreign_key "example_records", "structured_store_versioned_schemas", column: "structured_store_metadata_schema_id"
  add_foreign_key "example_records", "structured_store_versioned_schemas", column: "structured_store_settings_versioned_schema_id"
  add_foreign_key "example_records", "structured_store_versioned_schemas", column: "structured_store_store_versioned_schema_id"
  add_foreign_key "store_records", "structured_store_versioned_schemas", column: "structured_store_store_versioned_schema_id"
  add_foreign_key "text_store_records", "structured_store_versioned_schemas", column: "structured_store_store_versioned_schema_id"
  add_foreign_key "warehouse_records", "structured_store_versioned_schemas", column: "structured_store_warehouse_schema_id"
end
