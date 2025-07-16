class CreateStoreRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :store_records do |t|
      t.references :structured_store_store_versioned_schema,
                   null: false,
                   foreign_key: { to_table: :structured_store_versioned_schemas }
      t.json :store

      t.timestamps
    end
  end
end
