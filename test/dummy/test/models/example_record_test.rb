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

  test 'associations for versioned_schemas' do
    record = ExampleRecord.new(
      store_versioned_schema: structured_store_versioned_schemas(:party),
      metadata_schema: structured_store_versioned_schemas(:metadata),
      settings_versioned_schema: structured_store_versioned_schemas(:ui_preferences)
    )

    # Verify the store association
    association = record.class.reflect_on_association(:store_versioned_schema)
    assert_not_nil association
    assert_equal 'StructuredStore::VersionedSchema', association.class_name
    assert_equal 'structured_store_store_versioned_schema_id', association.foreign_key

    assert_equal structured_store_versioned_schemas(:party), record.store_versioned_schema

    # Verify the metadata association
    association = record.class.reflect_on_association(:metadata_schema)
    assert_not_nil association
    assert_equal 'StructuredStore::VersionedSchema', association.class_name
    assert_equal 'structured_store_metadata_schema_id', association.foreign_key

    assert_equal structured_store_versioned_schemas(:metadata), record.metadata_schema

    # Verify the settings association
    association = record.class.reflect_on_association(:settings_versioned_schema)
    assert_not_nil association
    assert_equal 'StructuredStore::VersionedSchema', association.class_name
    assert_equal 'structured_store_settings_versioned_schema_id', association.foreign_key

    assert_equal structured_store_versioned_schemas(:ui_preferences), record.settings_versioned_schema
  end

  test 'helper methods are defined correctly' do
    instance = ExampleRecord.new(
      store_versioned_schema: structured_store_versioned_schemas(:party),
      metadata_schema: structured_store_versioned_schemas(:metadata),
      settings_versioned_schema: structured_store_versioned_schemas(:ui_preferences)
    )

    # Check that store helper method is defined
    assert_respond_to instance, :store_json_schema
    assert_equal structured_store_versioned_schemas(:party).json_schema, instance.store_json_schema

    # Check that metadata helper method is defined
    assert_respond_to instance, :metadata_json_schema
    assert_equal structured_store_versioned_schemas(:metadata).json_schema, instance.metadata_json_schema

    # Check that settings helper method is defined
    assert_respond_to instance, :settings_json_schema
    assert_equal structured_store_versioned_schemas(:ui_preferences).json_schema, instance.settings_json_schema
  end

  test 'define_store_accessors_for_column works correctly' do
    instance = ExampleRecord.new

    refute_respond_to instance, :balloon_count  # from store
    refute_respond_to instance, :balloon_count= # from store
    refute_respond_to instance, :party_theme    # from store
    refute_respond_to instance, :party_theme=   # from store

    refute_respond_to instance, :created_by    # from metadata
    refute_respond_to instance, :created_by=   # from metadata
    refute_respond_to instance, :description   # from metadata
    refute_respond_to instance, :description=  # from metadata

    refute_respond_to instance, :display_mode   # from settings
    refute_respond_to instance, :display_mode=  # from settings
    refute_respond_to instance, :notifications  # from settings
    refute_respond_to instance, :notifications= # from settings

    instance.store_versioned_schema = structured_store_versioned_schemas(:party)
    instance.metadata_schema = structured_store_versioned_schemas(:metadata)
    instance.settings_versioned_schema = structured_store_versioned_schemas(:ui_preferences)
    # Define accessors for each structured store column
    instance.define_store_accessors_for_column('store')
    instance.define_store_accessors_for_column('metadata')
    instance.define_store_accessors_for_column('settings')

    # Should have accessors for metadata properties
    assert_respond_to instance, :balloon_count  # from store
    assert_respond_to instance, :balloon_count= # from store
    assert_respond_to instance, :party_theme    # from store
    assert_respond_to instance, :party_theme=   # from store

    assert_respond_to instance, :created_by    # from metadata
    assert_respond_to instance, :created_by=   # from metadata
    assert_respond_to instance, :description   # from metadata
    assert_respond_to instance, :description=  # from metadata

    assert_respond_to instance, :display_mode   # from settings
    assert_respond_to instance, :display_mode=  # from settings
    assert_respond_to instance, :notifications  # from settings
    assert_respond_to instance, :notifications= # from settings
  end

  test 'define_all_store_accessors! works correctly' do
    instance = ExampleRecord.new

    refute_respond_to instance, :balloon_count  # from store
    refute_respond_to instance, :balloon_count= # from store
    refute_respond_to instance, :party_theme    # from store
    refute_respond_to instance, :party_theme=   # from store

    refute_respond_to instance, :created_by     # from metadata
    refute_respond_to instance, :created_by=    # from metadata
    refute_respond_to instance, :description    # from metadata
    refute_respond_to instance, :description=   # from metadata

    refute_respond_to instance, :display_mode   # from settings
    refute_respond_to instance, :display_mode=  # from settings
    refute_respond_to instance, :notifications  # from settings
    refute_respond_to instance, :notifications= # from settings

    instance.store_versioned_schema = structured_store_versioned_schemas(:party)
    instance.metadata_schema = structured_store_versioned_schemas(:metadata)
    instance.settings_versioned_schema = structured_store_versioned_schemas(:ui_preferences)
    # Define accessors for all columns
    instance.define_all_store_accessors!

    # Should have accessors for metadata properties
    assert_respond_to instance, :balloon_count  # from store
    assert_respond_to instance, :balloon_count= # from store
    assert_respond_to instance, :party_theme    # from store
    assert_respond_to instance, :party_theme=   # from store

    assert_respond_to instance, :created_by     # from metadata
    assert_respond_to instance, :created_by=    # from metadata
    assert_respond_to instance, :description    # from metadata
    assert_respond_to instance, :description=   # from metadata

    assert_respond_to instance, :display_mode   # from settings
    assert_respond_to instance, :display_mode=  # from settings
    assert_respond_to instance, :notifications  # from settings
    assert_respond_to instance, :notifications= # from settings
  end
end
