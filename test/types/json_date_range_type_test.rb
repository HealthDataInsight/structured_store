# frozen_string_literal: true

require 'test_helper'

module StructuredStore
  class JsonDateRangeTypeTest < ActiveSupport::TestCase
    setup do
      @date_range_converter = mock
      @type = JsonDateRangeType.new(date_range_converter: @date_range_converter)
    end

    test 'cast returns string value when given a string' do
      assert_equal 'test string', @type.cast('test string')
    end

    test 'cast returns nil when hash is missing date1' do
      assert_nil @type.cast({ 'date2' => '2023-01-02' })
    end

    test 'cast converts hash dates to string range' do
      date1 = Date.new(2023, 1, 1)
      date2 = Date.new(2023, 1, 2)

      @date_range_converter.expects(:convert_to_string).
        with(date1, date2).
        returns('Jan 1-2 2023')

      result = @type.cast({
                            'date1' => '2023-01-01',
                            'date2' => '2023-01-02'
                          })

      assert_equal 'Jan 1-2 2023', result
    end

    test 'serialize returns nil for blank values' do
      assert_nil @type.serialize(nil)
      assert_nil @type.serialize('')
    end

    test 'serialize converts string to hash with formatted dates' do
      date1 = Date.new(2023, 1, 1)
      date2 = Date.new(2023, 1, 2)

      @date_range_converter.expects(:convert_to_dates).
        with('Jan 1-2 2023').
        returns([date1, date2])

      result = @type.serialize('Jan 1-2 2023')

      assert_equal({
                     'date1' => '2023-01-01',
                     'date2' => '2023-01-02'
                   }, result)
    end

    test 'serialize handles nil dates gracefully' do
      @date_range_converter.expects(:convert_to_dates).
        with('invalid').
        returns([nil, nil])

      result = @type.serialize('invalid')

      assert_equal({
                     'date1' => nil,
                     'date2' => nil
                   }, result)
    end
  end
end
