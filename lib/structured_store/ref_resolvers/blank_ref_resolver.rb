# frozen_string_literal: true

require 'structured_store/ref_resolvers/base'

module StructuredStore
  # This is the namespace for all reference resolvers used in StructuredStore.
  module RefResolvers
    # This class resolves properties where no $ref is defined.
    class BlankRefResolver < Base
      def self.matching_ref_pattern
        /\A\z/
      end

      # Defines the rails attribute(s) on the given singleton class
      #
      # @return [Proc] a lambda that defines the attribute on the singleton class
      # @raise [RuntimeError] if the property type is unsupported
      def define_attribute
        type = json_property_schema['type']

        # Handle arrays
        return define_array_attribute if type == 'array'

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
        # For arrays, get enum from items
        if json_property_schema['type'] == 'array'
          items_schema = json_property_schema['items'] || {}

          # If items has a $ref, resolve it to get the enum
          items_schema = resolve_items_ref(items_schema['$ref']) if items_schema['$ref']

          enum = items_schema['enum']
        else
          enum = json_property_schema['enum']
        end

        enum&.map { |option| [option, option] } || []
      end

      private

      # Defines an array attribute by delegating to the items type
      #
      # @return [Proc] a lambda that defines the array attribute
      def define_array_attribute
        items_schema = json_property_schema['items'] || {}

        # If items has a $ref, resolve it to get the actual type
        items_schema = resolve_items_ref(items_schema['$ref']) if items_schema['$ref']

        item_type = items_schema['type']

        unless %w[boolean integer string].include?(item_type)
          raise "Unsupported array item type: #{item_type.inspect} for property '#{property_name}'"
        end

        # Define the attribute on the singleton class of the object
        lambda do |object|
          object.singleton_class.attribute(property_name, :string)
        end
      end

      # Resolves a $ref in items to the actual definition
      #
      # @param ref_string [String] The $ref string to resolve
      # @return [Hash] The resolved definition
      def resolve_items_ref(ref_string)
        # Only handle #/definitions/ refs for now
        raise "Unsupported $ref in array items: #{ref_string}" unless ref_string.match?(%r{\A#/definitions/})

        definition_name = ref_string.sub('#/definitions/', '')
        definition = schema_inspector.definition_schema(definition_name)
        raise "No definition for #{ref_string}" if definition.nil?

        definition
      end
    end

    # Register the BlankRefResolver with the registry
    BlankRefResolver.register
  end
end
