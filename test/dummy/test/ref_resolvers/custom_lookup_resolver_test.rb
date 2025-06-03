# frozen_string_literal: true

require 'structured_store/ref_resolvers/defaults'
require_relative '../../lib/custom_lookup_resolver'
require 'test_helper'

# This class is an example of a lookup class that could be used with the CustomLookupResolver.
# It would typically be replaced with a real model class that interacts with the database.
# It provides a simple interface to retrieve the current lookups.
#
# In a real application, this would be replaced with the actual model class that
# interacts with the database, such as ActiveRecord or Mongoid.
class YesNoUnknown
  include ActiveModel::Model
  include ActiveModel::Attributes

  # This is a placeholder for the actual lookup class.
  # In a real application, this would be replaced with the actual model class.
  attribute :id, :integer
  attribute :label, :string

  def self.all_current_lookups
    [
      new(id: 1, label: 'Yes'),
      new(id: 2, label: 'No'),
      new(id: 3, label: 'Unknown')
    ]
  end
end

# Register the CustomLookupResolver with the registry
StructuredStore::RefResolvers::Registry.register(CustomLookupResolver)

module StructuredStore
  module RefResolvers
    # This class tests the CustomLookupResolver.
    class CustomLookupResolverTest < ActiveSupport::TestCase
      setup do
        CustomLookupResolver.register
      end

      teardown do
        CustomLookupResolver.unregister
      end

      test 'matching_ref_pattern' do
        assert_match CustomLookupResolver.matching_ref_pattern, 'external://custom_lookup/yeah_but_no_but_yeah_but_no'
        assert_match CustomLookupResolver.matching_ref_pattern, 'external://custom_lookup/yes_no_unknown'

        assert_no_match CustomLookupResolver.matching_ref_pattern, ''
        assert_no_match CustomLookupResolver.matching_ref_pattern, '#/definitions/foo'
        assert_no_match CustomLookupResolver.matching_ref_pattern, 'external://structured_store/json_date_range/'
      end

      test 'matching_resolver' do
        schema = {
          '$schema' => 'http://json-schema.org/draft/2019-09/schema#',
          'type' => 'object',
          'properties' => {
            'foo' => {
              '$ref' => 'external://custom_lookup/yes_no_unknown',
              'type' => 'string'
            }
          }
        }

        resolver = Registry.matching_resolver(schema, 'foo')
        assert_instance_of CustomLookupResolver, resolver
      end

      test 'define_attribute with integer attribute' do
        schema = {
          '$schema' => 'http://json-schema.org/draft/2019-09/schema#',
          'type' => 'object',
          'properties' => {
            'foo' => {
              '$ref' => 'external://custom_lookup/yes_no_unknown',
              'type' => 'integer'
            }
          }
        }

        store_record = StoreRecord.new(versioned_schema: VersionedSchema.new(json_schema: schema))

        # Now the structured store attribute "foo" should be defined
        assert_nil store_record.foo
        store_record.foo = 42
        assert_equal 42, store_record.foo
      end

      test 'define_attribute with untested attribute type' do
        schema = {
          '$schema' => 'http://json-schema.org/draft/2019-09/schema#',
          type: 'object',
          'properties' => {
            'foo' => {
              '$ref' => 'external://custom_lookup/yes_no_unknown',
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
              '$ref' => 'external://custom_lookup/yes_no_unknown',
              'type' => 'integer'
            }
          },
          'additionalProperties' => false
        }

        resolver = Registry.matching_resolver(schema, 'foo')
        assert_instance_of CustomLookupResolver, resolver
        assert_equal [[1, 'Yes'], [2, 'No'], [3, 'Unknown']], resolver.options_array
      end
    end
  end
end
