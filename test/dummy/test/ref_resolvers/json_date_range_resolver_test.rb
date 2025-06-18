# frozen_string_literal: true

require 'structured_store/ref_resolvers/defaults'
require 'structured_store/ref_resolvers/json_date_range_resolver'
require 'test_helper'

module StructuredStore
  module RefResolvers
    # This class tests the JsonDateRangeResolver.
    class JsonDateRangeResolverTest < ActiveSupport::TestCase
      test 'matching_ref_pattern' do
        assert_match JsonDateRangeResolver.matching_ref_pattern, 'external://structured_store/json_date_range/'

        assert_no_match JsonDateRangeResolver.matching_ref_pattern, ''
        assert_no_match JsonDateRangeResolver.matching_ref_pattern, '#/definitions/bar'
        assert_no_match JsonDateRangeResolver.matching_ref_pattern, '#/definitions/foo'
        assert_no_match JsonDateRangeResolver.matching_ref_pattern, 'external://custom_lookup/yes_no_unknown'
      end

      test 'matching_resolver' do
        resolver = Registry.matching_resolver(simple_foo_date_range_schema, 'foo')
        assert_instance_of JsonDateRangeResolver, resolver
      end

      test 'define_attribute with string attribute' do
        versioned_schema = VersionedSchema.new(name: 'DateRangeSchema',
                                               version: '0.1.0',
                                               json_schema: simple_foo_date_range_schema)
        store_record = StoreRecord.new(versioned_schema:)

        # Now the structured store attribute "foo" should be defined
        assert_nil store_record.foo
        store_record.foo = 'January 2024'
        assert_equal({ 'date1' => '2024-01-01 00:00:00', 'date2' => '2024-01-31 00:00:00' }, store_record.store['foo'])
        assert_equal 'Jan 2024', store_record.foo
      end

      test 'options_array' do
        schema = {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'properties' => {
            'foo' => {
              '$ref' => 'external://structured_store/json_date_range/'
            }
          },
          'additionalProperties' => false
        }

        schema_inspector = StructuredStore::SchemaInspector.new(schema)
        resolver = Registry.matching_resolver(schema_inspector, 'foo')
        assert_instance_of JsonDateRangeResolver, resolver

        assert_empty resolver.options_array
      end

      private

      def simple_foo_date_range_schema
        {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'properties' => {
            'foo' => {
              '$ref': 'external://structured_store/json_date_range/'
            }
          }
        }
      end
    end
  end
end
