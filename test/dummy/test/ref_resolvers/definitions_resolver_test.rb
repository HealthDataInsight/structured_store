# frozen_string_literal: true

require 'structured_store/ref_resolvers/defaults'
require 'test_helper'

module StructuredStore
  module RefResolvers
    # This class tests the DefinitionsResolver within a structured store record.
    class DefinitionsResolverTest < ActiveSupport::TestCase
      test 'define_attribute with string attribute' do
        schema = {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'definitions' => {
            'foo_lookup' => {
              'type' => 'string',
              'description' => 'A foo property'
            }
          },
          'properties' => {
            'foo' => {
              '$ref': '#/definitions/foo_lookup'
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
          'definitions' => {
            'foo_lookup' => {
              'type' => 'object'
            }
          },
          'properties' => {
            'foo' => {
              '$ref' => '#/definitions/foo_lookup'
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
