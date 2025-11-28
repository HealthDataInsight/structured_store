# frozen_string_literal: true

class CreateCustomSchemas < ActiveRecord::Migration[7.2]
  def change
    create_table :custom_schemas, primary_key: :schema_key do |t|
      t.string :name
      t.json :json_schema

      t.timestamps
    end
  end
end
