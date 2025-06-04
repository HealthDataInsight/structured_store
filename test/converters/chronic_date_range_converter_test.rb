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
end
