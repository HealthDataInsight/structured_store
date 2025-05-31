# frozen_string_literal: true

require 'structured_store/ref_resolvers/base'

module StructuredStore
  module RefResolvers
    # This class resolves properties where no $ref is defined.
    class BlankRefResolver < Base
      def initialize(schema, property_name, ref_string, context = {})
        super
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
  end
end
