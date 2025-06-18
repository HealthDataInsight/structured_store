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
        enum = json_property_schema['enum']

        enum.map { |option| [option, option] }
      end
    end

    # Register the BlankRefResolver with the registry
    BlankRefResolver.register
  end
end
