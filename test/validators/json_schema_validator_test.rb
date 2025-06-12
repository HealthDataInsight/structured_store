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
                  :hash_schema,
                  :instance_schema,
                  :openapi31_symbol_schema,
                  :string_schema,
                  :unexpected_class_schema

    validates :draft201909_symbol_schema, json_schema: { allow_blank: true, schema: :draft201909 }
    validates :hash_schema, json_schema: { allow_blank: true, schema: DRAFT201909_NAME_SCHEMA }
    validates :instance_schema, json_schema: { allow_blank: true, schema: JSONSchemer.schema(DRAFT201909_NAME_SCHEMA) }
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

  test 'unexpected class schema version' do
    object = JsonSchemaTestModel.new

    object.unexpected_class_schema = {
      'name' => 'John Doe'
    }
    assert_raises(ArgumentError) do
      object.valid?
    end
  end

  test 'json_schema_validator size limit' do
    object = JsonSchemaTestModel.new
    limit = JsonSchemaValidator::MAX_JSON_INPUT_SIZE_BYTES

    # Test with a string that is too large for hash_schema
    # Overhead for '{ "a": "" }' is 8 bytes. Plus 1 to exceed.
    padding_size = limit - '{"a":""}'.bytesize + 1
    large_json_string = "{ \"a\": \"#{'b' * padding_size}\" }"

    object.hash_schema = large_json_string
    assert_not object.valid? # Expecting validation to fail
    assert_includes object.errors.details[:hash_schema], { error: :json_too_large }

    # Test with a valid, small JSON string for hash_schema
    small_json_string = '{ "name": "Valid Name" }' # Complies with DRAFT201909_NAME_SCHEMA
    object.hash_schema = small_json_string
    assert object.valid?, "Object should be valid with small JSON: #{object.errors.full_messages.join(', ')}"
    error_details = object.errors.details[:hash_schema]
    assert_not error_details.any? { |e| e[:error] == :json_too_large }, "Should not have json_too_large error"
    assert_not error_details.any? { |e| e[:error] == :invalid_json }, "Should not have invalid_json error"

    # Additionally, ensure that a non-string value (already parsed JSON) doesn't trigger size check implicitly
    # and is still validated against the schema correctly.
    object.hash_schema = { 'name' => 123 } # Invalid according to DRAFT201909_NAME_SCHEMA (name should be string)
    assert_not object.valid?
    error_details = object.errors.details[:hash_schema]
    assert_not error_details.any? { |e| e[:error] == :json_too_large }, "Should not have json_too_large for pre-parsed JSON"
    assert error_details.any? { |e| e[:error].include?("is not a string") }, "Should have schema validation error for type mismatch"
  end
end
