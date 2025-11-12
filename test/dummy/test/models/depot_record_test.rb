require_relative '../../../test_helper'
require_relative '../helpers/store_accessor_test_helper'

# This tests the DepotRecord model which demonstrates explicit store configuration
class DepotRecordTest < ActiveSupport::TestCase
  test 'store configuration' do
    # Test that the model has explicitly configured the store
    configurations = DepotRecord._structured_store_configurations

    assert_equal 1, configurations.length

    config = configurations.first

    assert_equal 'depot', config[:column_name]
    assert_equal 'depot_versioned_schema', config[:schema_name]
  end

  test 'association for versioned_schema' do
    record = DepotRecord.new(depot_versioned_schema: structured_store_versioned_schemas(:metadata))

    # Verify no store association
    assert_nil record.class.reflect_on_association(:store_versioned_schema)

    # Verify the association properties
    association = record.class.reflect_on_association(:depot_versioned_schema)
    assert_not_nil association
    assert_equal 'StructuredStore::VersionedSchema', association.class_name
    assert_equal 'structured_store_depot_versioned_schema_id', association.foreign_key

    assert_equal structured_store_versioned_schemas(:metadata), record.depot_versioned_schema
  end

  test 'helper method is defined correctly' do
    instance = DepotRecord.new(depot_versioned_schema: structured_store_versioned_schemas(:metadata))

    # Check that helper method is defined
    assert_respond_to instance, :depot_json_schema
    assert_equal structured_store_versioned_schemas(:metadata).json_schema, instance.depot_json_schema
  end

  test 'define_store_accessors_for_column works correctly' do
    instance = DepotRecord.new

    refute_respond_to instance, :created_by
    refute_respond_to instance, :created_by=
    refute_respond_to instance, :description
    refute_respond_to instance, :description=
    refute_respond_to instance, :updated_by
    refute_respond_to instance, :updated_by=

    # Set the versioned schema and define accessors
    instance.depot_versioned_schema = structured_store_versioned_schemas(:metadata)
    instance.define_store_accessors_for_column('depot')

    # Should have accessors for depot properties
    assert_respond_to instance, :created_by
    assert_respond_to instance, :created_by=
    assert_respond_to instance, :description
    assert_respond_to instance, :description=
    assert_respond_to instance, :updated_by
    assert_respond_to instance, :updated_by=
  end

  test 'define_all_store_accessors! works correctly' do
    instance = DepotRecord.new

    refute_respond_to instance, :created_by
    refute_respond_to instance, :created_by=
    refute_respond_to instance, :description
    refute_respond_to instance, :description=
    refute_respond_to instance, :updated_by
    refute_respond_to instance, :updated_by=

    # Set the versioned schema and define accessors for all columns
    instance.depot_versioned_schema = structured_store_versioned_schemas(:metadata)
    instance.define_all_store_accessors!

    # Should have accessors for all store properties
    assert_respond_to instance, :created_by
    assert_respond_to instance, :created_by=
    assert_respond_to instance, :description
    assert_respond_to instance, :description=
    assert_respond_to instance, :updated_by
    assert_respond_to instance, :updated_by=
  end
end
