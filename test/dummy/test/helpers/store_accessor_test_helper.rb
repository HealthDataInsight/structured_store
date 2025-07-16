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

  def test_helper_method_is_defined_correctly
    instance = klass.new(store_versioned_schema: structured_store_versioned_schemas(:party))

    # Check that helper method is defined
    assert_respond_to instance, :store_json_schema
    assert_equal structured_store_versioned_schemas(:party).json_schema, instance.store_json_schema
  end

  def test_define_store_accessors
    record = klass.new(store_versioned_schema: structured_store_versioned_schemas(:party))

    assert record.respond_to?(:party_theme)
    assert record.respond_to?(:party_theme=)
    record.party_theme = 'Disco'

    assert record.respond_to?(:balloon_count)
    assert record.respond_to?(:balloon_count=)
    record.balloon_count = 42

    record.save!

    record = klass.find(record.id)

    assert record.respond_to?(:party_theme)
    assert record.respond_to?(:party_theme=)
    assert_equal 'Disco', record.party_theme

    assert record.respond_to?(:balloon_count)
    assert record.respond_to?(:balloon_count=)
    assert_equal 42, record.balloon_count
  end

  def test_define_store_accessors_for_column_works_correctly
    instance = klass.new

    refute_respond_to instance, :balloon_count
    refute_respond_to instance, :balloon_count=
    refute_respond_to instance, :party_theme
    refute_respond_to instance, :party_theme=

    # Set the versioned schema and define accessors
    instance.store_versioned_schema = structured_store_versioned_schemas(:party)
    instance.define_store_accessors_for_column('store')

    # Should have accessors for store properties
    assert_respond_to instance, :balloon_count
    assert_respond_to instance, :balloon_count=
    assert_respond_to instance, :party_theme
    assert_respond_to instance, :party_theme=
  end

  def test_define_all_store_accessors_works_correctly
    instance = klass.new

    refute_respond_to instance, :balloon_count
    refute_respond_to instance, :balloon_count=
    refute_respond_to instance, :party_theme
    refute_respond_to instance, :party_theme=

    # Set the versioned schema and define accessors for all columns
    instance.store_versioned_schema = structured_store_versioned_schemas(:party)
    instance.define_all_store_accessors!

    # Should have accessors for store properties
    assert_respond_to instance, :balloon_count
    assert_respond_to instance, :balloon_count=
    assert_respond_to instance, :party_theme
    assert_respond_to instance, :party_theme=
  end
end
