module StoreAccessorTestHelper
  def test_define_store_accessors
    record = klass.new(versioned_schema: total_count_versioned_schema)

    assert record.respond_to?(:theme)
    assert record.respond_to?(:theme=)
    record.theme = 'Disco'

    assert record.respond_to?(:total_count)
    assert record.respond_to?(:total_count=)
    record.total_count = 42

    record.save!

    record = klass.find(record.id)

    assert record.respond_to?(:theme)
    assert record.respond_to?(:theme=)
    assert_equal 'Disco', record.theme

    assert record.respond_to?(:total_count)
    assert record.respond_to?(:total_count=)
    assert_equal 42, record.total_count
  end

  private

  def total_count_versioned_schema
    versioned_schema = StructuredStore::VersionedSchema.new(name: 'Party', version: '0.10.0')

    versioned_schema.json_schema = <<~STR
      {
        "$schema": "https://json-schema.org/draft/2019-09/schema",
        "type": "object",
        "properties": {
          "theme": {
            "type": "string"
          },
          "total_count": {
            "type": "integer"
          }
        },
        "required": [],
        "additionalProperties": false
      }
    STR

    versioned_schema.save!
    versioned_schema
  end
end
