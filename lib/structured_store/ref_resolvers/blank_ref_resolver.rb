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
        type = property_schema['type']

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
      # For arrays, delegates to a resolver for the items to get options recursively
      #
      # @return [Array<Array>] Array of arrays containing id, value option pairs
      def options_array
        # For arrays, delegate to the items resolver
        if property_schema['type'] == 'array'
          items_resolver = create_items_resolver
          return items_resolver.options_array
        end

        # For non-arrays, get enum directly
        enum = property_schema['enum']
        enum&.map { |option| [option, option] } || []
      end

      private

      # Defines an array attribute by delegating to the items resolver
      #
      # @return [Proc] a lambda that defines the array attribute
      def define_array_attribute
        items_resolver = create_items_resolver

        # Get the item type - different resolvers expose this differently
        item_type = if items_resolver.is_a?(DefinitionsResolver)
                      # DefinitionsResolver stores type in the resolved definition
                      items_resolver.send(:local_definition)['type']
                    else
                      # BlankRefResolver has it directly in property_schema
                      items_resolver.property_schema['type']
                    end

        unless %w[boolean integer string].include?(item_type)
          raise "Unsupported array item type: #{item_type.inspect} for property '#{property_name}'"
        end

        # Define the attribute on the singleton class of the object
        lambda do |object|
          object.singleton_class.attribute(property_name, :string)
        end
      end

      # Creates a resolver for array items by delegating to the registry
      # This allows arrays to recursively use any resolver (BlankRefResolver, DefinitionsResolver, etc.)
      #
      # @return [Base] A resolver instance for the items
      def create_items_resolver
        items_schema = property_schema['items'] || {}
        items_ref = items_schema['$ref'].to_s

        # Use the registry to create a resolver for the items schema
        Registry.resolver_for_schema_hash(items_schema, items_ref, parent_schema, property_name, context)
      end
    end

    # Register the BlankRefResolver with the registry
    BlankRefResolver.register
  end
end
