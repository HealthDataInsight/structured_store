# frozen_string_literal: true

require 'structured_store/ref_resolvers/defaults'
require 'test_helper'

module StructuredStore
  module RefResolvers
    # This class tests the BlankRefResolver.
    class BlankRefResolverTest < ActiveSupport::TestCase
      test 'matching_ref_pattern' do
        assert_match BlankRefResolver.matching_ref_pattern, ''

        assert_no_match BlankRefResolver.matching_ref_pattern, '#/definitions/foo'
        assert_no_match BlankRefResolver.matching_ref_pattern, 'external://custom_lookup/yes_no_unknown'
        assert_no_match BlankRefResolver.matching_ref_pattern, 'external://structured_store/json_date_range/'
      end

      test 'matching_resolver' do
        schema = {
          '$schema' => 'http://json-schema.org/draft/2019-09/schema#',
          'type' => 'object',
          'properties' => {
            'foo' => {
              'type' => 'string',
              'description' => 'A foo property'
            }
          }
        }

        resolver = Registry.matching_resolver(schema, 'foo')
        assert_instance_of BlankRefResolver, resolver
      end

      test 'define_attribute with no attribute' do
        schema = {
          '$schema' => 'http://json-schema.org/draft/2019-09/schema#',
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
          '$schema' => 'http://json-schema.org/draft/2019-09/schema#',
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
          '$schema' => 'http://json-schema.org/draft/2019-09/schema#',
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

      test 'options_array' do
        schema = {
          '$schema' => 'http://json-schema.org/draft/2019-09/schema#',
          'type' => 'object',
          'properties' => {
            'foo' => {
              'type' => 'string',
              'enum' => %w[option1 option2 option3]
            }
          },
          'additionalProperties' => false
        }

        resolver = Registry.matching_resolver(schema, 'foo')
        assert_instance_of BlankRefResolver, resolver

        assert_equal [%w[option1 option1], %w[option2 option2], %w[option3 option3]], resolver.options_array
      end
    end
  end
end
