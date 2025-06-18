require 'test_helper'

#  This class tests the SchemaInspector for validating and accessing JSON Schemas.
class SchemaInspectorTest < ActiveSupport::TestCase
  test 'valid schema' do
    assert StructuredStore::SchemaInspector.new(hash_schema).valid_schema?

    refute StructuredStore::SchemaInspector.new(Marshal.dump("I'm not JSON")).valid_schema?
    refute StructuredStore::SchemaInspector.new(type: 'objet[sic]').valid_schema?
  end

  test 'schema size check' do
    schema_inspector = StructuredStore::SchemaInspector.new(JSON.dump(large_hash_schema))

    refute schema_inspector.valid_schema?
  end

  test 'property_schema with hash schema' do
    schema_inspector = StructuredStore::SchemaInspector.new(hash_schema)

    assert_equal({ 'type' => 'string' }, schema_inspector.property_schema('name'))
    assert_nil schema_inspector.property_schema(:non_existent_property)
  end

  test 'property_schema with string schema' do
    schema_inspector = StructuredStore::SchemaInspector.new(string_schema)

    assert_equal({ 'type' => 'string' }, schema_inspector.property_schema('name'))
    assert_nil schema_inspector.property_schema(:non_existent_property)
  end

  test 'definition_schema with hash schema' do
    schema_inspector = StructuredStore::SchemaInspector.new(hash_schema)

    assert_equal({ 'type' => 'string', 'enum' => %w[option1 option2 option3] }, schema_inspector.definition_schema('a_lookup'))
    assert_nil schema_inspector.definition_schema('non_existent_definition')
  end

  test 'definition_schema with string schema' do
    schema_inspector = StructuredStore::SchemaInspector.new(string_schema)

    assert_equal({ 'type' => 'string', 'enum' => %w[option1 option2 option3] }, schema_inspector.definition_schema('a_lookup'))
    assert_nil schema_inspector.definition_schema('non_existent_definition')
  end

  private

  def hash_schema
    {
      '$schema': 'https://json-schema.org/draft/2019-09/schema',
      type: 'object',
      definitions: {
        a_lookup: {
          type: 'string',
          enum: %w[option1 option2 option3]
        }
      },
      properties: {
        name: { type: 'string' },
        age: { type: 'integer' }
      }
    }
  end

  def string_schema
    JSON.dump(hash_schema)
  end

  def large_hash_schema
    @large_hash_schema ||= begin
      large_hash = JSON.parse(JSON.dump(hash_schema))

      large_hash['properties']['large_string'] = {
        'type' => 'string',
        'custom_property' => 'b' * StructuredStore::SchemaInspector::MAX_JSON_INPUT_SIZE_BYTES
      }

      large_hash
    end
  end
end
