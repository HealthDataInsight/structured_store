# frozen_string_literal: true

require 'structured_store/ref_resolvers/json_date_range_resolver'
require 'test_helper'

module StructuredStore
  module RefResolvers
    # This class tests the JsonDateRangeResolver.
    class JsonDateRangeResolverTest < ActiveSupport::TestCase
      test 'matching_resolver' do
        schema = {
          '$schema' => 'http://json-schema.org/draft/2019-09/schema#',
          'type' => 'object',
          'properties' => {
            'foo' => {
              '$ref': 'external://structured_store/json_date_range/'
            }
          }
        }

        resolver = Registry.matching_resolver(schema, 'foo')
        assert_instance_of JsonDateRangeResolver, resolver
      end

      test 'define_attribute with string attribute' do
        schema = {
          '$schema' => 'http://json-schema.org/draft/2019-09/schema#',
          'type' => 'object',
          'properties' => {
            'foo' => {
              '$ref': 'external://structured_store/json_date_range/'
            }
          }
        }

        store_record = StoreRecord.new(versioned_schema: VersionedSchema.new(json_schema: schema))

        # Now the structured store attribute "foo" should be defined
        assert_nil store_record.foo
        store_record.foo = { 'date1' => '2024-01-01', 'date2' => '2024-01-31' }
        assert_equal({ 'date1' => '2024-01-01', 'date2' => '2024-01-31' }, store_record.foo)
      end

      test 'options_array' do
        schema = {
          '$schema' => 'http://json-schema.org/draft/2019-09/schema#',
          'type' => 'object',
          'properties' => {
            'foo' => {
              '$ref' => 'external://structured_store/json_date_range/'
            }
          },
          'additionalProperties' => false
        }

        resolver = Registry.matching_resolver(schema, 'foo')
        assert_instance_of JsonDateRangeResolver, resolver

        assert_empty resolver.options_array
      end
    end
  end
end
