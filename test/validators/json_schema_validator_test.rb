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
    }

    DRAFT201909_NAME_SCHEMA = {
      '$schema' => 'https://json-schema.org/draft/2019-09/schema',
      'type' => 'object',
      'properties' => {
        'name' => {
          'type' => 'string',
          'example' => 'John Doe'
        }
      }
    }

    attr_accessor :draft201909_json_schema, :name_json, :openapi31_json_schema

    validates :draft201909_json_schema, json_schema: { allow_blank: true, schema: :draft201909 }
    validates :openapi31_json_schema, json_schema: { allow_blank: true, schema: :openapi31 }
    validates :name_json, json_schema: { allow_blank: true, schema: DRAFT201909_NAME_SCHEMA }
  end

  test 'valid constant schemas' do
    errors = JSONSchemer.openapi31.validate(JsonSchemaTestModel::OPENAPI31_USER_SCHEMA).to_a
    assert_empty errors

    errors = JSONSchemer.draft201909.validate(JsonSchemaTestModel::DRAFT201909_NAME_SCHEMA).to_a
    assert_empty errors

    errors = JSONSchemer.schema(JsonSchemaTestModel::DRAFT201909_NAME_SCHEMA).validate(
      { 'name' => 'John Doe' }
    ).to_a
    assert_empty errors
  end

  test 'named schema version' do
    object = JsonSchemaTestModel.new

    object.draft201909_json_schema = 'invalid_json'
    object.openapi31_json_schema = 'invalid_json'
    object.valid?
    assert_includes object.errors.details[:draft201909_json_schema], { error: :invalid_json }
    assert_includes object.errors.details[:openapi31_json_schema], { error: :invalid_json }

    object.draft201909_json_schema = JsonSchemaTestModel::DRAFT201909_NAME_SCHEMA
    object.openapi31_json_schema = JsonSchemaTestModel::OPENAPI31_USER_SCHEMA
    object.valid?
    assert_empty object.errors[:draft201909_json_schema]
    assert_empty object.errors[:openapi31_json_schema]
  end

  test 'hash schema version' do
    object = JsonSchemaTestModel.new

    object.name_json = 'invalid_json'
    object.valid?
    assert_includes object.errors.details[:name_json], { error: :invalid_json }

    object.name_json = {
      'name' => 'John Doe'
    }
    object.valid?
    assert_empty object.errors[:name_json]
  end
end

# class JsonSchemaValidator < ActiveModel::EachValidator
#   NAMED_SCHEMA_VERSIONS = %i[draft201909 draft202012 draft4 draft6 draft7 openapi30 openapi31].freeze

#   def validate_each(record, attribute, value)
#     # Convert value to hash if it's a string
#     json_data = value.is_a?(String) ? JSON.parse(value) : value

#     # Get the schema from options
#     schema = options[:schema] || options

#     # Initialize JSONSchemer with proper handling based on schema type
#     schemer = json_schemer(schema)

#     # Collect validation errors
#     validation_errors = schemer.validate(json_data).to_a

#     # Add errors to the record using json_schemer's built-in I18n support
#     validation_errors.each do |error|
#       record.errors.add(attribute, error['error'])
#     end
#   rescue JSON::ParserError
#     record.errors.add(attribute, :invalid_json)
#   end

#   private

#   # Converts given schema to a JSONSchemer::Schema object.
#   #
#   # Accepts either a symbol referencing a known schema (e.g. :draft7), a string
#   # or hash representing a schema, or a JSONSchemer::Schema object directly.
#   #
#   # Raises an ArgumentError if schema is in an unsupported format.
#   def json_schemer(schema)
#     case schema
#     when String, Hash
#       JSONSchemer.schema(schema)
#     when JSONSchemer::Schema
#       schema
#     else
#       raise ArgumentError, "Invalid schema format: #{schema.class}"
#     end
#   end
# end
