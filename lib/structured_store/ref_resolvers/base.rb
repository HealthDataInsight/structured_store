# frozen_string_literal: true

module StructuredStore
  module RefResolvers
    # This is the base class for all JSON Schema $ref resolvers.
    class Base
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

      # Resolves a reference to an item in a structured store
      #
      # @param ref_string [String] The reference string to resolve
      # @raise [NotImplementedError] Always raised as this is a base class method that must be implemented by subclasses
      def resolve
        raise NotImplementedError, 'Subclasses must implement a resolve method'
      end
    end
  end
end
