require_relative '../../../test_helper'
require_relative '../helpers/store_accessor_test_helper'

# This tests the StoreRecord model
class StoreRecordTest < ActiveSupport::TestCase
  include StoreAccessorTestHelper

  # test 'explicit configuration creates proper associations' do
  #   # Verify that calling structured_store :store explicitly
  #   # results in the same behavior as the default
  #   assert ExplicitStoreRecord.respond_to?(:_structured_store_configurations)

  #   configs = ExplicitStoreRecord._structured_store_configurations
  #   assert_equal 1, configs.size

  #   config = configs.first
  #   assert_equal :store, config[:column_name]
  #   assert_equal :store_versioned_schema, config[:schema_name]

  #   # Test association exists
  #   model = ExplicitStoreRecord.new
  #   assert model.respond_to?(:store_versioned_schema)
  #   assert model.respond_to?(:store_versioned_schema=)
  # end

  # test 'validation works with explicit configuration' do
  #   schema = create_validation_schema
  #   model = ExplicitStoreRecord.new(store_versioned_schema: schema)

  #   # Valid data should pass
  #   model.email = 'test@example.com'
  #   model.age = 25
  #   assert model.valid?

  #   # Invalid data should fail
  #   model.email = 'invalid-email'
  #   assert_not model.valid?
  #   assert model.errors[:store].present?
  # end

  # test 'accessors are defined correctly' do
  #   schema = total_count_versioned_schema
  #   model = ExplicitStoreRecord.new(store_versioned_schema: schema)

  #   # Check accessor methods exist
  #   assert model.respond_to?(:theme)
  #   assert model.respond_to?(:theme=)
  #   assert model.respond_to?(:total_count)
  #   assert model.respond_to?(:total_count=)

  #   # Test setting and getting values
  #   model.theme = 'Dark'
  #   model.total_count = 42

  #   assert_equal 'Dark', model.theme
  #   assert_equal 42, model.total_count

  #   # Verify data is stored in the store column
  #   expected_store = { 'theme' => 'Dark', 'total_count' => 42 }
  #   assert_equal expected_store, model.store
  # end

  # test 'works with different schema versions' do
  #   # Create version 1 schema
  #   schema_v1 = StructuredStore::VersionedSchema.create!(
  #     name: 'test_schema',
  #     version: '1.0.0',
  #     json_schema: {
  #       'type' => 'object',
  #       'properties' => {
  #         'name' => { 'type' => 'string' }
  #       }
  #     }
  #   )

  #   # Create version 2 schema with additional field
  #   schema_v2 = StructuredStore::VersionedSchema.create!(
  #     name: 'test_schema',
  #     version: '2.0.0',
  #     json_schema: {
  #       'type' => 'object',
  #       'properties' => {
  #         'name' => { 'type' => 'string' },
  #         'description' => { 'type' => 'string' }
  #       }
  #     }
  #   )

  #   # Test with v1 schema
  #   model_v1 = ExplicitStoreRecord.new(store_versioned_schema: schema_v1)
  #   assert model_v1.respond_to?(:name)
  #   assert_not model_v1.respond_to?(:description)

  #   # Test with v2 schema
  #   model_v2 = ExplicitStoreRecord.new(store_versioned_schema: schema_v2)
  #   assert model_v2.respond_to?(:name)
  #   assert model_v2.respond_to?(:description)
  # end

  private

  def klass
    ::ExplicitStoreRecord
  end

  # def create_validation_schema
  #   StructuredStore::VersionedSchema.create!(
  #     name: 'validation_test',
  #     version: '1.0.0',
  #     json_schema: {
  #       'type' => 'object',
  #       'properties' => {
  #         'email' => {
  #           'type' => 'string',
  #           'format' => 'email'
  #         },
  #         'age' => {
  #           'type' => 'integer',
  #           'minimum' => 0,
  #           'maximum' => 120
  #         }
  #       },
  #       'required' => ['email'],
  #       'additionalProperties' => false
  #     }
  #   )
  # end
end
