# frozen_string_literal: true

# This migration creates the underlying table for the structured store
class CreateStructuredStore < ActiveRecord::Migration[7.2]
  def change
    create_table :structured_store_versioned_schemas do |t|
      t.string :name, null: false
      t.string :version, null: false
      t.json :json_schema

      t.timestamps
    end

    # Add a unique index on the combination of name and version in versioned_schemas
    add_index :structured_store_versioned_schemas, %i[name version], unique: true
  end
end
