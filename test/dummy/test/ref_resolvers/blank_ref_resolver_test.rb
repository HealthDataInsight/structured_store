# frozen_string_literal: true

require 'structured_store/ref_resolvers/defaults'
require 'test_helper'

module StructuredStore
  module RefResolvers
    # This class tests the BlankRefResolver within a structured store record.
    class BlankRefResolverTest < ActiveSupport::TestCase
      test 'define_attribute with no attribute' do
        schema = {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'properties' => {}
        }

        store_record = StoreRecord.new(versioned_schema: VersionedSchema.new(json_schema: schema))

        # Ensure the structure store attribute is not defined
        assert_not_respond_to store_record, :foo
        assert_not_respond_to store_record, :foo=
      end

      test 'define_attribute with string attribute' do
        schema = {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'properties' => {
            'foo' => {
              'type' => 'string',
              'description' => 'A foo property'
            }
          }
        }

        store_record = StoreRecord.new(versioned_schema: VersionedSchema.new(json_schema: schema))

        # Now the structured store attribute "foo" should be defined
        assert_nil store_record.foo
        store_record.foo = 'bar'
        assert_equal 'bar', store_record.foo
      end

      test 'define_attribute with untested attribute type' do
        schema = {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'properties' => {
            'foo' => {
              'type' => 'object'
            }
          }
        }

        exception = assert_raises(RuntimeError) do
          StoreRecord.new(versioned_schema: VersionedSchema.new(json_schema: schema))
        end

        assert_equal 'Unsupported attribute type: "object" for property \'foo\'', exception.message
      end
    end
  end
end
