# frozen_string_literal: true

module StructuredStore
  module RefResolvers
    # This is the base class for all JSON Schema $ref resolvers.
    class Base
      attr_reader :context,
                  :property_name,
                  :ref_string,
                  :schema

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
      def initialize(schema, property_name, ref_string, context = {})
        @schema = schema
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

      private

      def json_property_definition
        @json_property_definition ||= schema.dig('properties', property_name)&.stringify_keys || {}
      end
    end
  end
end
