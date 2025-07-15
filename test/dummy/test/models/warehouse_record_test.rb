require_relative '../../../test_helper'
require_relative '../helpers/store_accessor_test_helper'

# This tests the WarehouseRecord model which demonstrates explicit store configuration
class WarehouseRecordTest < ActiveSupport::TestCase
  test 'store configuration' do
    # Test that the model has explicitly configured the store
    configurations = WarehouseRecord._structured_store_configurations

    assert_equal 1, configurations.length

    config = configurations.first

    assert_equal 'inventory', config[:column_name]
    assert_equal 'warehouse_schema', config[:schema_name]
  end

  test 'association for versioned_schema' do
    record = WarehouseRecord.new

    # Verify no store association
    assert_nil record.class.reflect_on_association(:store_versioned_schema)

    # Verify the association properties
    association = record.class.reflect_on_association(:warehouse_schema)
    assert_not_nil association
    assert_equal :warehouse_schema, association.name
    assert_equal 'StructuredStore::VersionedSchema', association.class_name
    assert_equal 'structured_store_warehouse_schema_id', association.foreign_key
  end

  # TODO: Add tests for WarehouseRecord model
end
