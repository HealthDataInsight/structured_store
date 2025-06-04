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
end
