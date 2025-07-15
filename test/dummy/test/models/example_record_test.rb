require_relative '../../../test_helper'
require_relative '../helpers/store_accessor_test_helper'

# This tests the ExampleRecord model which demonstrates explicit store configuration
class ExampleRecordTest < ActiveSupport::TestCase
  test 'store configuration' do
    # Test that the model has explicitly configured the store
    configurations = ExampleRecord._structured_store_configurations

    assert_equal 3, configurations.length

    assert_equal 'store', configurations[0][:column_name]
    assert_equal 'store_versioned_schema', configurations[0][:schema_name]
    assert_equal 'metadata', configurations[1][:column_name]
    assert_equal 'metadata_schema', configurations[1][:schema_name]
    assert_equal 'settings', configurations[2][:column_name]
    assert_equal 'settings_versioned_schema', configurations[2][:schema_name]
  end

  test 'association for store_versioned_schema' do
    record = ExampleRecord.new

    # Verify the store association
    association = record.class.reflect_on_association(:store_versioned_schema)
    assert_not_nil association
    assert_equal 'StructuredStore::VersionedSchema', association.class_name
    assert_equal 'structured_store_store_versioned_schema_id', association.foreign_key

    # Verify the metadata association
    association = record.class.reflect_on_association(:metadata_schema)
    assert_not_nil association
    assert_equal 'StructuredStore::VersionedSchema', association.class_name
    assert_equal 'structured_store_metadata_schema_id', association.foreign_key

    # Verify the settings association
    association = record.class.reflect_on_association(:settings_versioned_schema)
    assert_not_nil association
    assert_equal 'StructuredStore::VersionedSchema', association.class_name
    assert_equal 'structured_store_settings_versioned_schema_id', association.foreign_key
  end

  # TODO: Add tests for ExampleRecord model
end
