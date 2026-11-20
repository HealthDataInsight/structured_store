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
    record = WarehouseRecord.new(warehouse_schema: structured_store_versioned_schemas(:metadata))

    # Verify no store association
    assert_nil record.class.reflect_on_association(:store_versioned_schema)

    # Verify the association properties
    association = record.class.reflect_on_association(:warehouse_schema)
    assert_not_nil association
    assert_equal 'StructuredStore::VersionedSchema', association.class_name
    assert_equal 'structured_store_warehouse_schema_id', association.foreign_key

    assert_equal structured_store_versioned_schemas(:metadata), record.warehouse_schema
  end

  test 'helper method is defined correctly' do
    instance = WarehouseRecord.new(warehouse_schema: structured_store_versioned_schemas(:metadata))

    # Check that helper method is defined
    assert_respond_to instance, :inventory_json_schema
    assert_equal structured_store_versioned_schemas(:metadata).json_schema, instance.inventory_json_schema
  end

  test 'define_store_accessors_for_column works correctly' do
    assert_defines_inventory_accessors do |instance|
      instance.define_store_accessors_for_column('inventory')
    end
  end

  test 'define_all_store_accessors! works correctly' do
    assert_defines_inventory_accessors(&:define_all_store_accessors!)
  end

  private

  # Builds a WarehouseRecord, asserts no inventory accessors yet, assigns the
  # schema, yields the instance for accessor definition, then asserts they exist.
  def assert_defines_inventory_accessors
    instance = WarehouseRecord.new
    assert_inventory_accessors(instance, defined: false)

    # Set the versioned schema and define accessors
    instance.warehouse_schema = structured_store_versioned_schemas(:metadata)
    yield instance

    assert_inventory_accessors(instance, defined: true)
  end

  def assert_inventory_accessors(instance, defined:)
    assertion = defined ? :assert_respond_to : :refute_respond_to

    %i[created_by created_by= description description= updated_by updated_by=].each do |accessor|
      send(assertion, instance, accessor)
    end
  end
end
