# frozen_string_literal: true

# Example record with only a single custom-named store column and custom schema name
class WarehouseRecord < ApplicationRecord
  include StructuredStore::Storable

  # Only one store column called 'inventory' with custom schema association
  structured_store :inventory, schema_name: 'warehouse_schema'
end
