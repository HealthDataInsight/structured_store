# json_date_range
# frozen_string_literal: true

require 'structured_store/ref_resolvers/base'
require 'structured_store/types/json_date_range_type'

module StructuredStore
  # This is the namespace for all reference resolvers used in StructuredStore.
  module RefResolvers
    # This class resolves properties where no $ref is defined.
    class JsonDateRangeResolver < Base
      def self.matching_ref_pattern
        %r{\Aexternal://structured_store/json_date_range/}
      end

      # Defines the rails attribute(s) on the given singleton class
      #
      # @return [Proc] a lambda that defines the attribute on the singleton class
      # @raise [RuntimeError] if the property type is unsupported
      def define_attribute
        # Define the attribute on the singleton class of the object
        lambda do |object|
          object.singleton_class.attribute(property_name, :json_date_range,
                                           date_range_converter: object.date_range_converter)
        end
      end
    end

    # Register the JsonDateRangeResolver with the registry
    JsonDateRangeResolver.register
  end
end
