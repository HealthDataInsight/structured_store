require_relative "../../../test_helper"

# This tests the StoreRecord model
class StoreRecordTest < ActiveSupport::TestCase
  test 'delegated field_options' do
    versioned_schema = VersionedSchema.new

    versioned_schema.json_schema = <<~STR
      {
        "$schema": "http://json-schema.org/draft/2019-09/schema#",
        "type": "object",
        "properties": {
          "select_field": {
            "type": "string",
            "enum": ["option1", "option2", "option3"]
          }
        },
        "additionalProperties": false
      }
    STR

    versioned_schema.valid?
    assert_empty versioned_schema.errors.details[:json_schema]

    record = versioned_schema.records.build

    assert_equal %w[option1 option2 option3], record.field_options(:select_field)
  end

  test 'define_store_accessors!' do
    versioned_schema = VersionedSchema.new(name: 'Party', version: '0.10.0')

    versioned_schema.json_schema = <<~STR
      {
        "$schema": "http://json-schema.org/draft/2019-09/schema#",
        "type": "object",
        "properties": {
          "theme": {
            "type": "string"
          }
        },
        "required": [],
        "additionalProperties": false
      }
    STR

    versioned_schema.save!

    record = versioned_schema.records.build

    assert record.respond_to?(:theme)
    assert record.respond_to?(:theme=)

    record.theme = 'Disco'
    record.save!

    record = Record.find(record.id)

    assert record.respond_to?(:theme)
    assert record.respond_to?(:theme=)

    assert_equal 'Disco', record.theme
  end
end
