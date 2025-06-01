# frozen_string_literal: true

require 'test_helper'

module StructuredStore
  # This class contains the StructuredStore::VersionedSchema unit tests
  class VersionedSchemaTest < ActiveSupport::TestCase
    test 'fixture' do
      versioned_schema = StructuredStore::VersionedSchema.latest('MyAudit')

      assert_kind_of StructuredStore::VersionedSchema, versioned_schema
      assert_kind_of Hash, versioned_schema.json_schema
      assert_equal 'http://json-schema.org/draft/2019-09/schema#', versioned_schema.json_schema['$schema']
    end

    test 'json_schema validation' do
      versioned_schema = StructuredStore::VersionedSchema.new
      versioned_schema.valid?

      assert_empty versioned_schema.errors.details[:json_schema]

      versioned_schema.json_schema = JSON.dump(1)
      versioned_schema.valid?

      assert_includes versioned_schema.errors.details[:json_schema],
                      error: 'value at root is not one of the types: ["object", "boolean"]'

      versioned_schema.json_schema = <<~STR
        {
          "$schema": "http://json-schema.org/draft/2019-09/schema#",
          "type": "object",
          "properties": {
            "theme": {
              "type": "string",
              "description": "User interface theme preference"
            }
          },
          "required": ["theme"],
          "additionalProperties": false
        }
      STR
      versioned_schema.valid?

      assert_empty versioned_schema.errors.details[:json_schema]
    end

    test 'name validation' do
      versioned_schema = StructuredStore::VersionedSchema.new
      versioned_schema.valid?

      assert_includes versioned_schema.errors.details[:name], error: :blank

      versioned_schema.name = 'Potato'
      versioned_schema.valid?

      assert_not_includes versioned_schema.errors.details[:name], error: :blank
    end

    test 'field_options' do
      versioned_schema = StructuredStore::VersionedSchema.new

      versioned_schema.json_schema = <<~STR
        {
          "$schema": "http://json-schema.org/draft/2019-09/schema#",
          "type": "object",
          "definitions": {
            "yes_no": {
              "type": "string",
              "enum": [
                "Yes",
                "No"
              ],
              "description": "CCA No lookup"
            }
          },
          "properties": {
            "select_field": {
              "type": "string",
              "enum": ["option1", "option2", "option3"]
            },
            "select_field_via_local_definition": {
              "$ref": "#/definitions/yes_no",
              "description": "Evidence in patient’s records that patient was signposted to ..."
            }
          },
          "additionalProperties": false
        }
      STR

      assert_equal %w[option1 option2 option3], versioned_schema.field_options(:select_field)
      assert_equal %w[Yes No], versioned_schema.field_options(:select_field_via_local_definition)
    end

    test 'version validation' do
      versioned_schema = StructuredStore::VersionedSchema.new
      versioned_schema.valid?

      assert_includes versioned_schema.errors.details[:version], error: :blank

      versioned_schema.version = 'Potato'
      versioned_schema.valid?

      assert_not_includes versioned_schema.errors.details[:version], error: :blank
      assert_includes versioned_schema.errors.details[:version], { error: :invalid, value: 'Potato' }

      versioned_schema.version = '0.10.0'
      versioned_schema.valid?

      assert_not_includes versioned_schema.errors.details[:version], { error: :invalid, value: '0.10.0' }
    end
  end
end
