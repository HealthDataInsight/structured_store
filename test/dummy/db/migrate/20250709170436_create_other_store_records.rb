class CreateOtherStoreRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :binary_json_store_records do |t|
      t.references :structured_store_store_versioned_schema,
                   null: false,
                   foreign_key: { to_table: :structured_store_versioned_schemas }
      t.jsonb :store

      t.timestamps
    end

    create_table :binary_store_records do |t|
      t.references :structured_store_store_versioned_schema,
                   null: false,
                   foreign_key: { to_table: :structured_store_versioned_schemas }
      t.binary :store

      t.timestamps
    end

    create_table :text_store_records do |t|
      t.references :structured_store_store_versioned_schema,
                   null: false,
                   foreign_key: { to_table: :structured_store_versioned_schemas }
      t.text :store

      t.timestamps
    end

    # Example record demonstrating multiple structured store columns
    create_table :example_records do |t|
      t.string :name

      # Store columns (JSON fields)
      t.json :store
      t.json :metadata
      t.json :settings

      # Foreign keys to versioned schemas
      t.references :structured_store_store_versioned_schema,
                   null: false,
                   foreign_key: { to_table: :structured_store_versioned_schemas }
      t.references :structured_store_metadata_schema,
                   null: false,
                   foreign_key: { to_table: :structured_store_versioned_schemas }
      t.references :structured_store_settings_versioned_schema,
                   null: false,
                   foreign_key: { to_table: :structured_store_versioned_schemas }

      t.timestamps
    end

    # Example record with single custom-named store
    create_table :depot_records do |t|
      t.string :name

      # Single store column called 'depot'
      t.json :depot

      # Foreign key to versioned schema
      t.references :structured_store_depot_versioned_schema,
                   null: false,
                   foreign_key: { to_table: :structured_store_versioned_schemas }

      t.timestamps
    end

    # Example record with single custom-named store and custom schema association
    create_table :warehouse_records do |t|
      t.string :name

      # Single store column called 'inventory'
      t.json :inventory

      # Foreign key to versioned schema with custom name
      t.references :structured_store_warehouse_schema,
                   null: false,
                   foreign_key: { to_table: :structured_store_versioned_schemas }

      t.timestamps
    end
  end
end
