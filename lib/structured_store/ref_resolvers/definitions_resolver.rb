# frozen_string_literal: true

require 'structured_store/ref_resolvers/base'
require 'structured_store/ref_resolvers/registry'

module StructuredStore
  # This is the namespace for all reference resolvers used in StructuredStore.
  module RefResolvers
    # This class resolves $ref strings that point to definitions within the schema.
    class DefinitionsResolver < Base
      def self.matching_ref_pattern
        %r{\A#/definitions/}
      end

      def initialize(schema, property_name, ref_string, context = {})
        super
      end

      # Defines the rails attribute(s) on the given singleton class
      #
      # @return [Proc] a lambda that defines the attribute on the singleton class
      # @raise [RuntimeError] if the property type is unsupported
      def define_attribute
        type = local_definition['type']

        unless %w[boolean integer string].include?(type)
          raise "Unsupported attribute type: #{type.inspect} for property '#{property_name}'"
        end

        # Define the attribute on the singleton class of the object
        lambda do |object|
          object.singleton_class.attribute(property_name, type.to_sym)
        end
      end

      private

      # Retrieves a local definition from the schema based on the reference string
      #
      # @return [Hash] The local definition hash from the schema's definitions
      # @raise [RuntimeError] If no definition is found for the given reference string
      # @example
      #   resolver.local_definition  # => { "type" => "string" }
      def local_definition
        definition_name = ref_string.sub('#/definitions/', '')
        local_definition = schema.dig('definitions', definition_name) || {}

        raise "No definition for #{ref_string}" if local_definition.nil?

        local_definition
      end
    end

    # Register the DefinitionsResolver with the registry
    DefinitionsResolver.register
  end
end
