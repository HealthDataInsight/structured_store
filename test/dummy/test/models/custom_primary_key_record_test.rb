# frozen_string_literal: true

require_relative '../../../test_helper'

class CustomPrimaryKeyRecordTest < ActiveSupport::TestCase
  test 'store configuration' do
    # Test that the model has explicitly configured the store
    configurations = CustomPrimaryKeyRecord._structured_store_configurations

    assert_equal 1, configurations.length

    assert_equal 'settings', configurations[0][:column_name]
    assert_equal 'custom_schema', configurations[0][:schema_name]
  end

  test 'association uses custom class_name, foreign_key, and primary_key' do
    schema = custom_schemas(:theme_schema)
    record = CustomPrimaryKeyRecord.new(
      custom_schema: schema
    )

    # Verify the association properties
    association = record.class.reflect_on_association(:custom_schema)
    assert_not_nil association
    assert_equal 'CustomSchema', association.class_name
    assert_equal 'custom_schema_key', association.foreign_key
    assert_equal 'schema_key', association.options[:primary_key]

    assert_equal schema, record.custom_schema
  end

  test 'helper method is defined correctly' do
    instance = CustomPrimaryKeyRecord.new(
      custom_schema: custom_schemas(:theme_schema)
    )

    # Check that settings helper method is defined
    assert_respond_to instance, :settings_json_schema
    assert_equal custom_schemas(:theme_schema).json_schema, instance.settings_json_schema
  end

  test 'define_store_accessors_for_column works correctly' do
    # Before setting schema, accessors should not exist
    instance = CustomPrimaryKeyRecord.new

    refute_respond_to instance, :color_scheme   # from settings
    refute_respond_to instance, :color_scheme=  # from settings
    refute_respond_to instance, :font_size      # from settings
    refute_respond_to instance, :font_size=     # from settings

    instance.custom_schema = custom_schemas(:theme_schema)
    instance.define_store_accessors_for_column('settings')

    # Should have accessors for settings properties
    assert_respond_to instance, :color_scheme
    assert_respond_to instance, :color_scheme=
    assert_respond_to instance, :font_size
    assert_respond_to instance, :font_size=
  end

  test 'can save and load record with custom primary_key' do
    schema = custom_schemas(:theme_schema)
    record = CustomPrimaryKeyRecord.create!(
      name: 'Test Record',
      custom_schema: schema
    )

    # Verify the custom foreign key column is set correctly using the custom primary key
    assert_equal schema.schema_key, record.custom_schema_key
    assert_equal schema.schema_key, record.reload.custom_schema_key

    # Verify the association still works after reload
    assert_equal schema, record.reload.custom_schema
  end

  test 'accessors work with custom schema' do
    schema = custom_schemas(:theme_schema)
    record = CustomPrimaryKeyRecord.new(
      custom_schema: schema,
      settings: { color_scheme: 'dark', font_size: 14 }
    )

    # Accessors should be defined
    assert_equal 'dark', record.color_scheme
    assert_equal 14, record.font_size

    # Should be able to update via accessors
    record.color_scheme = 'light'
    record.font_size = 16

    assert_equal 'light', record.color_scheme
    assert_equal 16, record.font_size
    assert_equal({ 'color_scheme' => 'light', 'font_size' => 16 }, record.settings)
  end

  test 'works with different schema from same custom class' do
    layout_schema = custom_schemas(:layout_schema)
    record = CustomPrimaryKeyRecord.new(
      custom_schema: layout_schema,
      settings: { sidebar_position: 'left', header_style: 'fixed' }
    )

    # Should have accessors for layout schema properties
    assert_respond_to record, :sidebar_position
    assert_respond_to record, :header_style

    assert_equal 'left', record.sidebar_position
    assert_equal 'fixed', record.header_style
  end

  test 'foreign key references correct primary key' do
    schema = custom_schemas(:theme_schema)
    record = CustomPrimaryKeyRecord.create!(
      name: 'FK Test',
      custom_schema: schema
    )

    # The foreign_key should reference the custom primary_key value
    assert_equal schema.schema_key, record.custom_schema_key

    # Should be able to find the schema using the foreign key
    found_schema = CustomSchema.find_by(schema_key: record.custom_schema_key)
    assert_equal schema, found_schema
  end
end
