# frozen_string_literal: true

require 'structured_store/ref_resolvers/base'

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
        # Capture the property name in a local variable for closure
        prop_name = property_name
        resolver = self

        # Define the attribute on the singleton class of the object
        lambda do |object|
          converter = object.date_range_converter

          # Define custom getter and setter methods
          object.singleton_class.define_method(prop_name) do
            resolver.send(:cast_stored_value, store, prop_name, converter)
          end

          object.singleton_class.define_method("#{prop_name}=") do |value|
            resolver.send(:serialize_value_to_store, self, prop_name, value, converter)
          end
        end
      end

      # Returns an empty array of options for date ranges
      #
      # @return [Array<Array>] Array of arrays containing id, value option pairs
      def options_array
        []
      end

      private

      # Casts the stored value from hash to formatted string
      def cast_stored_value(store_hash, prop_name, converter)
        stored_value = store_hash&.[](prop_name)
        return nil if stored_value.blank?

        case stored_value
        when String
          stored_value
        when Hash
          cast_hash_to_string(stored_value, converter)
        end
      end

      # Converts a hash with date1/date2 to a formatted string
      def cast_hash_to_string(stored_value, converter)
        return nil unless stored_value['date1']

        date1 = Date.parse(stored_value['date1'])
        date2 = Date.parse(stored_value['date2'])
        converter.convert_to_string(date1, date2)
      end

      # Serializes an input value to the store as a hash
      def serialize_value_to_store(object, prop_name, value, converter)
        # Initialize store as empty hash if nil
        object.store ||= {}
        return object.store[prop_name] = nil if value.blank?

        date1, date2 = converter.convert_to_dates(value)
        object.store[prop_name] = {
          'date1' => date1&.to_fs(:db),
          'date2' => date2&.to_fs(:db)
        }
      end
    end

    # Register the JsonDateRangeResolver with the registry
    JsonDateRangeResolver.register
  end
end
