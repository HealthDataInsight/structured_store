require_relative '../../../test_helper'
require_relative '../helpers/store_accessor_test_helper'

# This tests the StoreRecord model
class StoreRecordTest < ActiveSupport::TestCase
  include StoreAccessorTestHelper

  test 'works with different schema versions' do
    # Create version 1 schema
    schema_v1 = StructuredStore::VersionedSchema.create!(
      name: 'test_schema',
      version: '1.0.0',
      json_schema: {
        'type' => 'object',
        'properties' => {
          'name' => { 'type' => 'string' }
        }
      }
    )

    # Create version 2 schema with additional field
    schema_v2 = StructuredStore::VersionedSchema.create!(
      name: 'test_schema',
      version: '2.0.0',
      json_schema: {
        'type' => 'object',
        'properties' => {
          'name' => { 'type' => 'string' },
          'description' => { 'type' => 'string' }
        }
      }
    )

    # Test with v1 schema
    record_v1 = StoreRecord.new(store_versioned_schema: schema_v1)
    assert record_v1.respond_to?(:name)
    assert_not record_v1.respond_to?(:description)

    # Test with v2 schema
    record_v2 = StoreRecord.new(store_versioned_schema: schema_v2)
    assert record_v2.respond_to?(:name)
    assert record_v2.respond_to?(:description)
  end

  private

  def klass
    ::StoreRecord
  end
end
