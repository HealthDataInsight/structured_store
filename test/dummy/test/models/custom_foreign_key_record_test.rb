# frozen_string_literal: true

require_relative '../../../test_helper'

# This tests the CustomForeignKeyRecord model which demonstrates custom foreign_key option
class CustomForeignKeyRecordTest < ActiveSupport::TestCase
  test 'store configuration' do
    # Test that the model has explicitly configured the store
    configurations = CustomForeignKeyRecord._structured_store_configurations

    assert_equal 1, configurations.length

    assert_equal 'preferences', configurations[0][:column_name]
    assert_equal 'preferences_versioned_schema', configurations[0][:schema_name]
  end

  test 'association uses custom foreign_key' do
    record = CustomForeignKeyRecord.new(
      preferences_versioned_schema: structured_store_versioned_schemas(:ui_preferences)
    )

    # Verify the preferences association
    association = record.class.reflect_on_association(:preferences_versioned_schema)
    assert_not_nil association
    assert_equal 'StructuredStore::VersionedSchema', association.class_name

    # This is the key test - verify it uses the custom foreign key
    assert_equal 'my_custom_schemaid', association.foreign_key

    assert_equal structured_store_versioned_schemas(:ui_preferences), record.preferences_versioned_schema
  end

  test 'helper method is defined correctly' do
    instance = CustomForeignKeyRecord.new(
      preferences_versioned_schema: structured_store_versioned_schemas(:ui_preferences)
    )

    # Check that preferences helper method is defined
    assert_respond_to instance, :preferences_json_schema
    assert_equal structured_store_versioned_schemas(:ui_preferences).json_schema, instance.preferences_json_schema
  end

  test 'define_store_accessors_for_column works correctly' do
    instance = CustomForeignKeyRecord.new

    refute_respond_to instance, :display_mode   # from preferences
    refute_respond_to instance, :display_mode=  # from preferences
    refute_respond_to instance, :notifications  # from preferences
    refute_respond_to instance, :notifications= # from preferences

    instance.preferences_versioned_schema = structured_store_versioned_schemas(:ui_preferences)
    instance.define_store_accessors_for_column('preferences')

    # Should have accessors for preferences properties
    assert_respond_to instance, :display_mode   # from preferences
    assert_respond_to instance, :display_mode=  # from preferences
    assert_respond_to instance, :notifications  # from preferences
    assert_respond_to instance, :notifications= # from preferences
  end

  test 'can save and load record with custom foreign_key' do
    schema = structured_store_versioned_schemas(:ui_preferences)
    record = CustomForeignKeyRecord.create!(
      name: 'Test Record',
      preferences_versioned_schema: schema
    )

    # Verify the custom foreign key column is set correctly
    assert_equal schema.id, record.my_custom_schemaid
    assert_equal schema.id, record.reload.my_custom_schemaid

    # Verify we can still access through the association
    assert_equal schema, record.preferences_versioned_schema
  end
end
