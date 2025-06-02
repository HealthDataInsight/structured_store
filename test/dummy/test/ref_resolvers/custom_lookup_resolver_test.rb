# frozen_string_literal: true

require 'structured_store/ref_resolvers/registry'
require 'test_helper'

class CustomLookupResolver < StructuredStore::RefResolvers::Base
  def self.matching_ref_pattern
    %r{\Aexternal://custom_lookup/}
  end

  # Defines the rails attribute(s) on the given singleton class
  #
  # @return [Proc] a lambda that defines the attribute on the singleton class
  # @raise [RuntimeError] if the property type is unsupported
  def define_attribute
    type = json_property_definition['type']

    unless %w[boolean integer string].include?(type)
      raise "Unsupported attribute type: #{type.inspect} for property '#{property_name}'"
    end

    # Define the attribute on the singleton class of the object
    lambda do |object|
      object.singleton_class.attribute(property_name, type.to_sym)
    end
  end
end

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

      test 'matching_resolver' do
        schema = {
          '$schema' => 'http://json-schema.org/draft/2019-09/schema#',
          'type' => 'object',
          'properties' => {
            'foo' => {
              '$ref': 'external://custom_lookup/zyesnounknown',
              'type' => 'string'
            }
          }
        }

        resolver = Registry.matching_resolver(schema, 'foo')
        assert_instance_of CustomLookupResolver, resolver
      end
      # "select_field_via_registered_resolver": {
      #   "$ref": "external://custom_lookup/zyesnounknown",
      #   "description": "Property that uses a registered resolver for custom lookup"
      # }
      # assert_equal %w[Foo Bar Baz], versioned_schema.field_options(:select_field_via_registered_resolver)

      test 'define_attribute with string attribute' do
        schema = {
          '$schema' => 'http://json-schema.org/draft/2019-09/schema#',
          'type' => 'object',
          'definitions' => {
            'foo_lookup' => {
              'type' => 'string',
              'description' => 'A foo property'
            }
          },
          'properties' => {
            'foo' => {
              '$ref' => 'external://custom_lookup/zyesnounknown',
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
              '$ref' => 'external://custom_lookup/zyesnounknown',
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
