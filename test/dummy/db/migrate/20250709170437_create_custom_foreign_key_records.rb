# frozen_string_literal: true

class CreateCustomForeignKeyRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :custom_foreign_key_records do |t|
      t.string :name
      t.json :preferences
      t.bigint :my_custom_schemaid, null: false

      t.timestamps
    end

    add_index :custom_foreign_key_records, :my_custom_schemaid
    add_foreign_key :custom_foreign_key_records, :structured_store_versioned_schemas, column: :my_custom_schemaid
  end
end
