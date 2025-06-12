require 'test_helper'

#  This class tests the SchemaInspector for validating and accessing JSON Schemas.
class SchemaInspectorTest < ActiveSupport::TestCase
  test 'valid schema' do
    assert StructuredStore::SchemaInspector.new(name_and_age_schema).valid_schema?

    refute StructuredStore::SchemaInspector.new(Marshal.dump("I'm not JSON")).valid_schema?
    refute StructuredStore::SchemaInspector.new(type: 'objet[sic]').valid_schema?
  end

  private

  def name_and_age_schema
    {
      '$schema' => 'https://json-schema.org/draft/2019-09/schema',
      'type' => 'object',
      'properties' => {
        'name' => { 'type' => 'string' },
        'age' => { 'type' => 'integer' }
      }
    }
  end
end
