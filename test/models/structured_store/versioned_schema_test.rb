# frozen_string_literal: true

require 'test_helper'

module StructuredStore
  # This class contains the StructuredStore::VersionedSchema unit tests
  class VersionedSchemaTest < ActiveSupport::TestCase
    test 'fixture' do
      versioned_schema = StructuredStore::VersionedSchema.latest('MyAudit')

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

    test 'json_schema size validation' do
      versioned_schema = StructuredStore::VersionedSchema.new(name: 'TestSchema', version: '1.0.0')
      limit = StructuredStore::VersionedSchema::MAX_JSON_INPUT_SIZE_BYTES

      # Test with a string that is too large
      # Constructing a JSON string like '{ "a": "b...b" }' where 'b...b' makes the total size exceed the limit.
      # The overhead is for '{"a":""}' which is 8 bytes. Plus 1 for the extra char to exceed.
      padding_size = limit - '{"a":""}'.bytesize + 1
      large_json_string = "{ \"a\": \"#{'b' * padding_size}\" }"

      assert_raises(ArgumentError, "JSON input exceeds maximum allowed size of #{limit} bytes") do
        versioned_schema.json_schema = large_json_string
      end

      # Test with a valid, small JSON string
      small_json_string = '{ "a": "b" }'
      assert_nothing_raised do
        versioned_schema.json_schema = small_json_string
      end
      assert_equal({ 'a' => 'b' }, versioned_schema.json_schema)
      assert versioned_schema.valid?, "Schema should be valid with small JSON: #{versioned_schema.errors.full_messages.join(', ')}"
    end
  end
end
