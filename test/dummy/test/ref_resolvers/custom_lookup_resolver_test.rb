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
    # You could hard-code the type if it were always the same,
    # but it makes the JSON schema more declarative
    type = json_property_definition['type']

    unless %w[boolean integer string].include?(type)
      raise "Unsupported attribute type: #{type.inspect} for property '#{property_name}'"
    end

    # Define the attribute on the singleton class of the object
    lambda do |object|
      object.singleton_class.attribute(property_name, type.to_sym)
    end
  end

  # Returns a two dimensional array of options from the 'enum' property definition
  # Each element contains a duplicate of the enum option for both the label and value
  #
  # @return [Array<Array>] Array of arrays containing id, value option pairs
  def options_array
    klass_name = ref_string.sub('external://custom_lookup/', '')
    klass = klass_name.camelize.constantize

    # A complete implementation would check if the class is a lookup class
    # For example, you might check if it includes a specific module or inherits from a base class
    # raise(SecurityError, 'Not a lookup class') unless klass.ancestors.include?(...)

    klass.all_current_lookups.map do |lookup|
      [lookup.id, lookup.label]
    end
  end
end

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
