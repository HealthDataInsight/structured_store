# frozen_string_literal: true

require 'test_helper'

module StructuredStore
  # This class contains the StructuredStore::VersionedSchema unit tests
  class VersionedSchemaTest < ActiveSupport::TestCase
    test 'fixture' do
      versioned_schema = StructuredStore::VersionedSchema.latest('UIPreferences')

      assert_kind_of StructuredStore::VersionedSchema, versioned_schema
      assert_kind_of Hash, versioned_schema.json_schema
      assert_equal 'https://json-schema.org/draft/2019-09/schema', versioned_schema.json_schema['$schema']
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
          "$schema": "https://json-schema.org/draft/2019-09/schema",
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
