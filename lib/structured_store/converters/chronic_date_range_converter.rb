# frozen_string_literal: true

require 'chronic'

module StructuredStore
  module Converters
    # This class is responsible for converting date ranges to and from a string format.
    class ChronicDateRangeConverter
      # Converts a natural language date range string into an array containing start and end dates
      #
      # @param value [String] A natural language date range string (e.g., "between 1st and 15th January 2024")
      # @return [Array<Time>] An array containing two Time objects: [start_date, end_date]
      # @raise [NoMethodError] If the input string cannot be parsed into a valid date range
      def convert_to_dates(value)
        return [nil, nil] if value.blank?

        if /\A\d{4}\z/.match?(value.strip)
          # If the value is a year, return the start and end of that year
          year = value.strip.to_i
          return [Time.new(year, 1, 1), Time.new(year, 12, 31)]
        end

        parsed_date_range = Chronic.parse(value, endian_precedence: :little, guess: false)

        [parsed_date_range&.begin, parsed_date_range&.end&.days_ago(1)]
      end

      # Formats two dates into a human readable date range string
      #
      # @param date1 [Date] The start date of the range
      # @param date2 [Date] The end date of the range
      # @return [String] A formatted date range string in one of these formats:
      #   - "D MMM YYYY" (when dates are equal)
      #   - "MMM YYYY" (when dates span a full month in the same year)
      #   - "YYYY" (when dates span a full year)
      #   - "D MMM YYYY to D MMM YYYY" (for all other date ranges)
      # @example
      #   convert_to_string(Date.new(2023,1,1), Date.new(2023,1,1)) #=> "1 Jan 2023"
      #   convert_to_string(Date.new(2023,1,1), Date.new(2023,1,31)) #=> "Jan 2023"
      #   convert_to_string(Date.new(2023,1,1), Date.new(2023,12,31)) #=> "2023"
      #   convert_to_string(Date.new(2023,1,1), Date.new(2023,2,1)) #=> "1 Jan 2023 to 1 Feb 2023"
      def convert_to_string(date1, date2)
        return format_single_date(date1) if date1 == date2
        return format_full_month(date1) if full_month_range?(date1, date2)
        return format_full_year(date1) if full_year_range?(date1, date2)

        format_date_range(date1, date2)
      end

      private

      # Formats a single date
      def format_single_date(date)
        date.strftime('%e %b %Y').strip
      end

      # Formats a full month
      def format_full_month(date)
        date.strftime('%b %Y')
      end

      # Formats a full year
      def format_full_year(date)
        date.strftime('%Y')
      end

      # Formats a date range
      def format_date_range(date1, date2)
        "#{date1.strftime('%e %b %Y').strip} to #{date2.strftime('%e %b %Y').strip}"
      end

      # Checks if the date range spans a full month
      def full_month_range?(date1, date2)
        date1.year == date2.year &&
          date1.month == date2.month &&
          date1 == date1.beginning_of_month &&
          date2 == date2.end_of_month
      end

      # Checks if the date range spans a full year
      def full_year_range?(date1, date2)
        date1.year == date2.year &&
          date1 == date1.beginning_of_year &&
          date2 == date2.end_of_year
      end
    end
  end
end
