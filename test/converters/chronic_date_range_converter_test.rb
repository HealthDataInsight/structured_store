# frozen_string_literal: true

require 'test_helper'
require 'date'

class ChronicDateRangeConverterTest < ActiveSupport::TestCase
  def setup
    @converter = StructuredStore::Converters::ChronicDateRangeConverter.new
  end

  test 'convert_to_dates specific date' do
    date1, date2 = @converter.convert_to_dates('16th Jan 2024')
    assert_equal Time.new(2024, 1, 16), date1
    assert_equal Time.new(2024, 1, 16), date2
  end

  test 'convert_to_dates month' do
    date1, date2 = @converter.convert_to_dates('February 2024')
    assert_equal Time.new(2024, 2, 1), date1
    assert_equal Time.new(2024, 2, 29), date2
  end

  test 'convert_to_dates year' do
    date1, date2 = @converter.convert_to_dates('2024')
    assert_equal Time.new(2024, 1, 1), date1
    assert_equal Time.new(2024, 12, 31), date2
  end

  test 'convert_to_dates invalid input' do
    date1, date2 = @converter.convert_to_dates('invalid date range')
    assert_nil date1
    assert_nil date2
  end

  test 'convert to string same date' do
    date = Date.new(2023, 1, 1)
    assert_equal '1 Jan 2023', @converter.convert_to_string(date, date)
  end

  test 'convert to string full month' do
    start_date = Date.new(2023, 1, 1)
    end_date = Date.new(2023, 1, 31)
    assert_equal 'Jan 2023', @converter.convert_to_string(start_date, end_date)
  end

  test 'convert to string full year' do
    start_date = Date.new(2023, 1, 1)
    end_date = Date.new(2023, 12, 31)
    assert_equal '2023', @converter.convert_to_string(start_date, end_date)
  end

  test 'convert to string date range' do
    start_date = Date.new(2023, 1, 1)
    end_date = Date.new(2024, 1, 17)
    assert_equal '1 Jan 2023 to 17 Jan 2024', @converter.convert_to_string(start_date, end_date)
  end

  test 'convert_to_dates input length limit' do
    limit = StructuredStore::Converters::ChronicDateRangeConverter::MAX_CHRONIC_INPUT_LENGTH
    long_date_string = 'a' * (limit + 1)

    date1, date2 = @converter.convert_to_dates(long_date_string)
    assert_nil date1, "Start date should be nil for overly long input"
    assert_nil date2, "End date should be nil for overly long input"

    # Test with a string that is exactly at the limit (should still be processed, might be valid or invalid Chronic input)
    # This specific string is unlikely to be a valid date, so Chronic.parse will likely return nil
    # leading to [nil, nil], but it shouldn't be caught by the length check itself.
    at_limit_string = 'a' * limit
    date1_at_limit, date2_at_limit = @converter.convert_to_dates(at_limit_string)
    # We expect Chronic to fail parsing this, thus returning nils.
    # The key is that it's not the length check that returns nils.
    assert_nil date1_at_limit, "Start date should be nil for at-limit non-date string"
    assert_nil date2_at_limit, "End date should be nil for at-limit non-date string"


    # Test with a blank string (should be handled by blank? check)
    blank_date_string = ''
    date1_blank, date2_blank = @converter.convert_to_dates(blank_date_string)
    assert_nil date1_blank
    assert_nil date2_blank

    # Test with a valid year string (should be handled by year check)
    year_string = '2023'
    date1_year, date2_year = @converter.convert_to_dates(year_string)
    assert_equal Time.new(2023, 1, 1), date1_year
    assert_equal Time.new(2023, 12, 31), date2_year
  end
end
