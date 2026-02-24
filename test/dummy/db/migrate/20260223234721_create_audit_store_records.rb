# frozen_string_literal: true

# Creates the audit_store_records table used by AuditStoreRecord.
# This table is intentionally named with "audit_store" (not "store") as the JSON column
# to serve as a regression fixture for JsonDateRangeResolver column-name handling.
class CreateAuditStoreRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :audit_store_records do |t|
      t.references :structured_store_audit_store_versioned_schema,
                   null: false,
                   foreign_key: { to_table: :structured_store_versioned_schemas }
      t.json :audit_store

      t.timestamps
    end
  end
end
