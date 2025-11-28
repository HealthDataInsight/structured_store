# frozen_string_literal: true

class CreateCustomPrimaryKeyRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :custom_primary_key_records do |t|
      t.string :name
      t.bigint :custom_schema_key
      t.json :settings

      t.timestamps
    end

    add_index :custom_primary_key_records, :custom_schema_key
  end
end
