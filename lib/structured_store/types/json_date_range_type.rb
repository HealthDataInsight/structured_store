# frozen_string_literal: true

module StructuredStore
  # This file defines an ActiveRecord type for handling chronic parsed date ranges stored as hashes.
  class JsonDateRangeType < ActiveRecord::Type::Value
    def initialize(date_range_converter:)
      super()
      @date_range_converter = date_range_converter
    end

    def cast(value)
      case value
      when String
        value
      when Hash
        return nil unless value['date1']

        date1 = Date.parse(value['date1'])
        date2 = Date.parse(value['date2'])

        @date_range_converter.convert_to_string(date1, date2)
      end
    end

    def serialize(value)
      return nil if value.blank?

      date1, date2 = @date_range_converter.convert_to_dates(value)

      {
        'date1' => date1&.to_fs(:db),
        'date2' => date2&.to_fs(:db)
      }
    end
  end
end

# Register the type with ActiveRecord
ActiveRecord::Type.register(:json_date_range, StructuredStore::JsonDateRangeType)
