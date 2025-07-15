module StoreAccessorTestHelper
  def test_store_configuration
    # Test that the model has explicitly configured the store
    configurations = klass._structured_store_configurations

    assert_equal 1, configurations.length

    config = configurations.first

    assert_equal 'store', config[:column_name]
    assert_equal 'store_versioned_schema', config[:schema_name]
  end

  def test_association_for_versioned_schema
    record = klass.new

    # Verify the association properties
    association = record.class.reflect_on_association(:store_versioned_schema)
    assert_not_nil association
    assert_equal 'StructuredStore::VersionedSchema', association.class_name
    assert_equal 'structured_store_store_versioned_schema_id', association.foreign_key
  end

  def test_define_store_accessors
    record = klass.new(store_versioned_schema: total_count_versioned_schema)

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
    StructuredStore::VersionedSchema.find_or_create_by!(name: 'Party', version: '0.10.0') do |schema|
      schema.json_schema = <<~STR
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
    end
  end
end
