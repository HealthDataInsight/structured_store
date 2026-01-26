# frozen_string_literal: true

require 'test_helper'

class RailsErrorMapperTest < ActiveSupport::TestCase
  # Dummy record class for testing error mapping without requiring a real ActiveRecord model
  class DummyRecord
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :name, :email, :age, :score, :price, :discount, :username, :bio,
                  :website, :id, :birth_date, :code, :count, :status, :country,
                  :items, :quantity, :config, :user
  end

  setup do
    @record = DummyRecord.new
  end

  test 'initializes with json_error and record' do
    json_error = { 'type' => 'required' }
    mapper = RailsErrorMapper.new(json_error, @record)

    assert_equal json_error, mapper.json_error
    assert_equal @record, mapper.record
  end

  test 'call returns true when error type has a handler' do
    json_error = {
      'type' => 'minimum',
      'data_pointer' => '/age',
      'schema' => { 'minimum' => 18 }
    }

    mapper = RailsErrorMapper.new(json_error, @record)

    assert mapper.call
    assert @record.errors.details[:age].present?
  end

  test 'call returns nil when error type has no handler' do
    json_error = {
      'type' => 'unknown_error_type',
      'data_pointer' => '/field'
    }

    mapper = RailsErrorMapper.new(json_error, @record)

    assert_nil mapper.call
    assert @record.errors.empty?
  end

  # Required errors
  test 'maps required errors to blank errors for missing keys' do
    json_error = {
      'type' => 'required',
      'data_pointer' => '/',
      'details' => { 'missing_keys' => %w[name email] }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :blank }
    assert_includes @record.errors.details[:name], expected_error
    assert_includes @record.errors.details[:email], expected_error
  end

  test 'handles required errors with nil missing_keys' do
    json_error = {
      'type' => 'required',
      'data_pointer' => '/',
      'details' => {}
    }

    mapper = RailsErrorMapper.new(json_error, @record)

    assert_nothing_raised { mapper.call }
  end

  # Numeric range errors
  test 'maps minimum errors' do
    json_error = {
      'type' => 'minimum',
      'data_pointer' => '/age',
      'schema' => { 'minimum' => 18 }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :greater_than_or_equal_to, count: 18 }
    assert_includes @record.errors.details[:age], expected_error
  end

  test 'maps maximum errors' do
    json_error = {
      'type' => 'maximum',
      'data_pointer' => '/score',
      'schema' => { 'maximum' => 100 }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :less_than_or_equal_to, count: 100 }
    assert_includes @record.errors.details[:score], expected_error
  end

  test 'maps exclusiveMinimum errors' do
    json_error = {
      'type' => 'exclusiveMinimum',
      'data_pointer' => '/price',
      'schema' => { 'exclusiveMinimum' => 0 }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :greater_than, count: 0 }
    assert_includes @record.errors.details[:price], expected_error
  end

  test 'maps exclusiveMaximum errors' do
    json_error = {
      'type' => 'exclusiveMaximum',
      'data_pointer' => '/discount',
      'schema' => { 'exclusiveMaximum' => 1 }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :less_than, count: 1 }
    assert_includes @record.errors.details[:discount], expected_error
  end

  # Length/size errors
  test 'maps minLength errors' do
    json_error = {
      'type' => 'minLength',
      'data_pointer' => '/username',
      'schema' => { 'minLength' => 3 }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :too_short, count: 3 }
    assert_includes @record.errors.details[:username], expected_error
  end

  test 'maps maxLength errors' do
    json_error = {
      'type' => 'maxLength',
      'data_pointer' => '/bio',
      'schema' => { 'maxLength' => 500 }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :too_long, count: 500 }
    assert_includes @record.errors.details[:bio], expected_error
  end

  # Format errors
  test 'maps email format errors' do
    json_error = {
      'type' => 'format',
      'data_pointer' => '/email',
      'schema' => { 'format' => 'email' }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :invalid_email }
    assert_includes @record.errors.details[:email], expected_error
  end

  test 'maps uri format errors' do
    json_error = {
      'type' => 'format',
      'data_pointer' => '/website',
      'schema' => { 'format' => 'uri' }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :invalid_url }
    assert_includes @record.errors.details[:website], expected_error
  end

  test 'maps uuid format errors' do
    json_error = {
      'type' => 'format',
      'data_pointer' => '/id',
      'schema' => { 'format' => 'uuid' }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :invalid_uuid }
    assert_includes @record.errors.details[:id], expected_error
  end

  test 'maps date format errors' do
    json_error = {
      'type' => 'format',
      'data_pointer' => '/birth_date',
      'schema' => { 'format' => 'date' }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :invalid_date }
    assert_includes @record.errors.details[:birth_date], expected_error
  end

  test 'maps unknown format errors' do
    json_error = {
      'type' => 'format',
      'data_pointer' => '/custom_field',
      'schema' => { 'format' => 'unknown-format' }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :invalid_format }
    assert_includes @record.errors.details[:custom_field], expected_error
  end

  # Pattern errors
  test 'maps pattern validation errors' do
    json_error = {
      'type' => 'pattern',
      'data_pointer' => '/code',
      'schema' => { 'pattern' => '^[A-Z]{3}$' }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :invalid_format }
    assert_includes @record.errors.details[:code], expected_error
  end

  # Type errors
  test 'maps type validation errors' do
    json_error = {
      'type' => 'type',
      'data_pointer' => '/count',
      'schema' => { 'type' => 'integer' }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :invalid_type, type: 'integer' }
    assert_includes @record.errors.details[:count], expected_error
  end

  # Enum errors
  test 'maps enum errors with few values' do
    json_error = {
      'type' => 'enum',
      'data_pointer' => '/status',
      'schema' => { 'enum' => %w[active inactive pending] }
    }
    @record.status = 'invalid'

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :enum_inclusion_short_list, value: 'invalid', values: 'active, inactive, pending' }
    assert_includes @record.errors.details[:status], expected_error
  end

  test 'maps enum errors with many values' do
    json_error = {
      'type' => 'enum',
      'data_pointer' => '/country',
      'schema' => { 'enum' => %w[US UK FR DE IT ES] }
    }
    @record.country = 'XX'

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :inclusion, value: 'XX' }
    assert_includes @record.errors.details[:country], expected_error
  end

  test 'maps uniqueItems errors' do
    json_error = {
      'type' => 'uniqueItems',
      'data_pointer' => '/items',
      'schema' => { 'uniqueItems' => true }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :non_unique_items }
    assert_includes @record.errors.details[:items], expected_error
  end

  test 'maps multipleOf errors' do
    json_error = {
      'type' => 'multipleOf',
      'data_pointer' => '/quantity',
      'schema' => { 'multipleOf' => 5 }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :not_multiple_of, multiple: 5 }
    assert_includes @record.errors.details[:quantity], expected_error
  end

  test 'maps additionalProperties errors' do
    json_error = {
      'type' => 'additionalProperties',
      'data_pointer' => '/config',
      'schema' => { 'additionalProperties' => false }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    expected_error = { error: :unexpected_properties }
    assert_includes @record.errors.details[:config], expected_error
  end

  # Extract attribute tests
  test 'extracts attribute from simple pointer' do
    json_error = {
      'type' => 'minimum',
      'data_pointer' => '/age',
      'schema' => { 'minimum' => 18 }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    assert @record.errors.details[:age].present?
  end

  test 'extracts last part of nested pointer' do
    json_error = {
      'type' => 'minimum',
      'data_pointer' => '/user/age',
      'schema' => { 'minimum' => 18 }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    # Should extract 'age' as the last part of the pointer
    assert @record.errors.details[:age].present?
  end

  test 'handles root pointer as base' do
    json_error = {
      'type' => 'additionalProperties',
      'data_pointer' => '/',
      'schema' => { 'additionalProperties' => false }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    assert @record.errors.details[:base].present?
  end

  test 'handles blank pointer as base' do
    json_error = {
      'type' => 'additionalProperties',
      'data_pointer' => '',
      'schema' => { 'additionalProperties' => false }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    assert @record.errors.details[:base].present?
  end

  test 'handles deeply nested pointers' do
    json_error = {
      'type' => 'minimum',
      'data_pointer' => '/user/contact/email',
      'schema' => { 'minimum' => 1 }
    }

    mapper = RailsErrorMapper.new(json_error, @record)
    mapper.call

    # Should extract 'email' as the last part of the pointer
    assert @record.errors.details[:email].present?
  end
end
