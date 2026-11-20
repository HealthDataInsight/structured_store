# frozen_string_literal: true

# Shared assertions for RefResolver tests that build a StoreRecord from a JSON
# schema and exercise the generated "foo" accessor.
module RefResolverTestHelper
  def build_store_record(schema)
    StoreRecord.new(store_versioned_schema: StructuredStore::VersionedSchema.new(json_schema: schema))
  end

  def assert_foo_string_accessor(schema)
    store_record = build_store_record(schema)

    assert_nil store_record.foo
    store_record.foo = 'bar'
    assert_equal 'bar', store_record.foo
  end

  def assert_unsupported_foo_type_raises(schema)
    exception = assert_raises(RuntimeError) do
      build_store_record(schema)
    end

    assert_equal 'Unsupported attribute type: "object" for property \'foo\'', exception.message
  end
end
