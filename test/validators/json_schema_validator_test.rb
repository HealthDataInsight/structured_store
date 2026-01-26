# frozen_string_literal: true

require 'test_helper'

class JsonSchemaValidatorTest < ActiveSupport::TestCase
  class JsonSchemaTestModel
    include ActiveModel::Validations

    OPENAPI31_USER_SCHEMA = {
      'openapi' => '3.1.0',
      'info' => {
        'title' => 'Test API',
        'version' => '1.0.0'
      },
      'paths' => {},
      'components' => {
        'schemas' => {
          'User' => {
            'type' => 'object',
            'properties' => {
              'name' => {
                'type' => 'string',
                'description' => "The user's full name"
              }
            },
            'required' => ['name']
          }
        }
      }
    }.freeze

    DRAFT201909_NAME_SCHEMA = {
      '$schema' => 'https://json-schema.org/draft/2019-09/schema',
      'type' => 'object',
      'properties' => {
        'name' => {
          'type' => 'string',
          'example' => 'John Doe'
        }
      }
    }.freeze

    attr_accessor :draft201909_symbol_schema,
                  :email,
                  :hash_schema,
                  :instance_schema,
                  :lambda_schema,
                  :lambda_schema_dynamic,
                  :openapi31_symbol_schema,
                  :string_schema,
                  :unexpected_class_schema

    validates :draft201909_symbol_schema, json_schema: { allow_blank: true, schema: :draft201909 }
    validates :hash_schema, json_schema: { allow_blank: true, schema: DRAFT201909_NAME_SCHEMA }
    validates :instance_schema, json_schema: { allow_blank: true, schema: JSONSchemer.schema(DRAFT201909_NAME_SCHEMA) }
    validates :lambda_schema, json_schema: {
      allow_blank: true,
      convert_to_rails_errors: true,
      schema: lambda { |_record, _attribute, value|
        # Return a JSON schema hash based on the value
        if value.is_a?(Hash) && value.key?('email')
          {
            'type' => 'object',
            'properties' => {
              'name' => { 'type' => 'string' },
              'email' => { 'type' => 'string', 'format' => 'email' }
            },
            'required' => %w[name email]
          }
        else
          {
            'type' => 'object',
            'properties' => {
              'name' => { 'type' => 'string' }
            },
            'required' => ['name']
          }
        end
      }
    }
    validates :lambda_schema_dynamic, json_schema: {
      allow_blank: true,
      schema: lambda { |record, _attribute, _value|
        # Return different schemas based on record state
        if record.respond_to?(:use_openapi?) && record.use_openapi?
          :openapi31
        else
          DRAFT201909_NAME_SCHEMA
        end
      }
    }
    validates :openapi31_symbol_schema, json_schema: { allow_blank: true, schema: :openapi31 }
    validates :string_schema, json_schema: { allow_blank: true, schema: DRAFT201909_NAME_SCHEMA.to_json }
    validates :unexpected_class_schema, json_schema: { allow_blank: true, schema: self }
  end

  test 'validate test schemas' do
    errors = JSONSchemer.openapi31.validate(JsonSchemaTestModel::OPENAPI31_USER_SCHEMA).to_a
    assert_empty errors

    errors = JSONSchemer.draft201909.validate(JsonSchemaTestModel::DRAFT201909_NAME_SCHEMA).to_a
    assert_empty errors

    errors = JSONSchemer.schema(JsonSchemaTestModel::DRAFT201909_NAME_SCHEMA).validate(
      { 'name' => 'John Doe' }
    ).to_a
    assert_empty errors
  end

  test 'symbol schema version' do
    object = JsonSchemaTestModel.new

    object.draft201909_symbol_schema = 'invalid_json'
    object.openapi31_symbol_schema = 'invalid_json'
    object.valid?
    assert_includes object.errors.details[:draft201909_symbol_schema], { error: :invalid_json }
    assert_includes object.errors.details[:openapi31_symbol_schema], { error: :invalid_json }

    object.draft201909_symbol_schema = JsonSchemaTestModel::DRAFT201909_NAME_SCHEMA
    object.openapi31_symbol_schema = JsonSchemaTestModel::OPENAPI31_USER_SCHEMA
    object.valid?
    assert_empty object.errors.details[:draft201909_symbol_schema]
    assert_empty object.errors.details[:openapi31_symbol_schema]
  end

  test 'hash schema version' do
    assert_kind_of Hash, JsonSchemaTestModel::DRAFT201909_NAME_SCHEMA

    object = JsonSchemaTestModel.new

    object.hash_schema = 'invalid_json'
    object.valid?
    assert_includes object.errors.details[:hash_schema], { error: :invalid_json }

    object.hash_schema = {
      'name' => 'John Doe'
    }
    object.valid?
    assert_empty object.errors.details[:hash_schema]
  end

  test 'instance schema version' do
    assert_kind_of JSONSchemer::Schema, JSONSchemer.schema(JsonSchemaTestModel::DRAFT201909_NAME_SCHEMA)

    object = JsonSchemaTestModel.new

    object.instance_schema = 'invalid_json'
    object.valid?
    assert_includes object.errors.details[:instance_schema], { error: :invalid_json }

    object.instance_schema = {
      'name' => 'John Doe'
    }
    object.valid?
    assert_empty object.errors.details[:instance_schema]
  end

  test 'string schema version' do
    assert_kind_of String, JsonSchemaTestModel::DRAFT201909_NAME_SCHEMA.to_json

    object = JsonSchemaTestModel.new

    object.string_schema = 'invalid_json'
    object.valid?
    assert_includes object.errors.details[:string_schema], { error: :invalid_json }

    object.string_schema = {
      'name' => 'John Doe'
    }
    object.valid?
    assert_empty object.errors.details[:string_schema]

    object.string_schema = {
      'name' => 42
    }
    object.valid?
    assert_includes object.errors.details[:string_schema], { error: 'value at `/name` is not a string' }
  end

  test 'lambda schema version with rails error conversion' do
    object = JsonSchemaTestModel.new

    object.lambda_schema = 'invalid_json'
    object.valid?
    assert_includes object.errors.details[:lambda_schema], { error: :invalid_json }

    # Test with basic name-only schema (no email key)
    object.lambda_schema = {
      'name' => 'John Doe'
    }
    object.valid?
    assert_empty object.errors.details[:lambda_schema]

    # Test with email schema (has email key)
    object.lambda_schema = {
      'name' => 'John Doe',
      'email' => 'john@example.com'
    }
    object.valid?
    assert_empty object.errors.details[:lambda_schema]

    # Test validation failure with email schema - missing required name
    object.lambda_schema = {
      'email' => 'john@example.com'
    }
    object.valid?

    expected_blank_error = { error: :blank }
    assert_includes object.errors.details[:name], expected_blank_error
    assert_empty object.errors.details[:lambda_schema], 'Blank error should have been remove from lambda_schema attribute'

    # Test validation failure with email schema - invalid email format
    object.lambda_schema = {
      'name' => 'John Doe',
      'email' => 'invalid-email'
    }
    object.valid?
    expected_format_error = { error: :invalid_email }
    assert_includes object.errors.details[:email], expected_format_error
    assert_empty object.errors.details[:lambda_schema], 'Format error should have been remove from lambda_schema attribute'
  end

  test 'lambda schema dynamic version' do
    object = JsonSchemaTestModel.new

    # Test with default behavior (use DRAFT201909_NAME_SCHEMA)
    object.lambda_schema_dynamic = {
      'name' => 'John Doe'
    }
    object.valid?
    assert_empty object.errors.details[:lambda_schema_dynamic]

    # Test with dynamic schema selection
    object.define_singleton_method(:use_openapi?) { true }
    object.lambda_schema_dynamic = {
      'openapi' => '3.1.0',
      'info' => {
        'title' => 'Test API',
        'version' => '1.0.0'
      },
      'paths' => {}
    }
    object.valid?
    assert_empty object.errors.details[:lambda_schema_dynamic]

    # Test validation failure with dynamic schema - switch back to DRAFT201909_NAME_SCHEMA
    object.define_singleton_method(:use_openapi?) { false }
    object.lambda_schema_dynamic = {
      'name' => 42 # Should fail - name must be string in DRAFT201909_NAME_SCHEMA
    }
    object.valid?
    assert_not_empty object.errors.details[:lambda_schema_dynamic]
  end

  test 'unexpected class schema version' do
    object = JsonSchemaTestModel.new

    object.unexpected_class_schema = {
      'name' => 'John Doe'
    }
    assert_raises(ArgumentError) do
      object.valid?
    end
  end
end
