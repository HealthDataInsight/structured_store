class CreateOtherStoreRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :binary_json_store_records do |t|
      t.references :structured_store_versioned_schema, null: false, foreign_key: true,
                                                       index: { name: 'index_jsonb_ss_records_on_versioned_schema_id' }
      t.jsonb :store

      t.timestamps
    end

    create_table :binary_store_records do |t|
      t.references :structured_store_versioned_schema, null: false, foreign_key: true,
                                                       index: { name: 'index_bin_ss_records_on_versioned_schema_id' }
      t.binary :store

      t.timestamps
    end

    create_table :text_store_records do |t|
      t.references :structured_store_versioned_schema, null: false, foreign_key: true,
                                                       index: { name: 'index_text_records_on_versioned_schema_id' }
      t.text :store

      t.timestamps
    end
  end
end
