class CreateStoreRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :store_records do |t|
      t.references :structured_store_versioned_schema, null: false, foreign_key: true,
                                                       index: { name: 'index_ss_records_on_versioned_schema_id' }
      t.json :store

      t.timestamps
    end
  end
end
