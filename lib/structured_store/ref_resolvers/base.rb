# frozen_string_literal: true

module StructuredStore
  module RefResolvers
    # This is the base class for all JSON Schema $ref resolvers.
    class Base
      attr_reader :context,
                  :property_name,
                  :ref_string,
                  :schema_inspector

      class << self
        def matching_ref_pattern
          raise NotImplementedError, 'Subclasses must implement the matching_ref_pattern method'
        end

        def register
          StructuredStore::RefResolvers::Registry.register(self)
        end

        def unregister
          StructuredStore::RefResolvers::Registry.unregister(self)
        end
      end

      # Initialize method for the base reference resolver
      #
      # @param schema [Hash] JSON Schema for the resolver
      # @param options [Hash] Additional options for the resolver
      def initialize(schema_inspector, property_name, ref_string, context = {})
        @schema_inspector = schema_inspector
        @property_name = property_name
        @ref_string = ref_string
        @context = context
      end

      # Defines the rails attribute(s) on the given singleton class
      #
      # @abstract Subclasses must implement this method
      # @return [Proc] a lambda that defines the attribute on the singleton class
      # @raise [NotImplementedError] if the method is not implemented in a subclass
      def define_attribute
        raise NotImplementedError, 'Subclasses must implement the define_attribute method'
      end

      # Returns a two dimensional array of HTML select box options
      #
      # This method must be implemented by subclasses to provide specific options
      # for reference resolution.
      #
      # @abstract Subclasses must implement this method
      # @return [Array<Array>] Array of arrays containing id, value option pairs
      # @raise [NotImplementedError] if the method is not implemented by a subclass
      def options_array
        raise NotImplementedError, 'Subclasses must implement the options_array method'
      end

      private

      def json_property_schema
        @json_property_schema ||= schema_inspector.property_schema(property_name) || {}
      end
    end
  end
end
