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

  def test_setting_store_attributes_with_new
    # Test setting store attributes via new with mass assignment
    record = klass.new(
      store_versioned_schema: structured_store_versioned_schemas(:party),
      party_theme: 'Hawaiian',
      balloon_count: 25
    )

    assert_equal 'Hawaiian', record.party_theme
    assert_equal 25, record.balloon_count
    assert_not record.persisted?

    # Save and verify persistence
    record.save!
    assert record.persisted?

    # Reload and verify values were saved correctly
    reloaded_record = klass.find(record.id)
    assert_equal 'Hawaiian', reloaded_record.party_theme
    assert_equal 25, reloaded_record.balloon_count
  end

  def test_setting_store_attributes_with_create
    # Test setting store attributes via create with mass assignment
    record = klass.create(
      store_versioned_schema: structured_store_versioned_schemas(:party),
      party_theme: 'Masquerade',
      balloon_count: 50
    )

    assert record.persisted?
    assert_equal 'Masquerade', record.party_theme
    assert_equal 50, record.balloon_count

    # Reload and verify values persisted
    reloaded_record = klass.find(record.id)
    assert_equal 'Masquerade', reloaded_record.party_theme
    assert_equal 50, reloaded_record.balloon_count
  end

  def test_setting_store_attributes_with_create_bang
    # Test setting store attributes via create! with mass assignment
    record = klass.create!(
      store_versioned_schema: structured_store_versioned_schemas(:party),
      party_theme: 'Carnival',
      balloon_count: 100
    )

    assert record.persisted?
    assert_equal 'Carnival', record.party_theme
    assert_equal 100, record.balloon_count

    # Reload and verify values persisted
    reloaded_record = klass.find(record.id)
    assert_equal 'Carnival', reloaded_record.party_theme
    assert_equal 100, reloaded_record.balloon_count
  end

  def test_setting_store_attributes_without_schema_with_new
    # Test that store attributes cannot be set without a schema
    # When no schema is provided, unknown attributes should raise an error
    assert_raises(ActiveModel::UnknownAttributeError) do
      klass.new(
        party_theme: 'Theme without schema',
        balloon_count: 10
      )
    end
  end

  def test_updating_store_attributes_after_creation
    # Create a record with initial store values via mass assignment
    record = klass.create!(
      store_versioned_schema: structured_store_versioned_schemas(:party),
      party_theme: 'Beach Party',
      balloon_count: 30
    )

    # Update the store attributes
    record.party_theme = 'Tropical Paradise'
    record.balloon_count = 60
    record.save!

    # Reload and verify updates
    reloaded_record = klass.find(record.id)
    assert_equal 'Tropical Paradise', reloaded_record.party_theme
    assert_equal 60, reloaded_record.balloon_count
  end

  def test_setting_partial_store_attributes
    # Test setting only some store attributes (party schema doesn't require any fields)
    record = klass.create!(
      store_versioned_schema: structured_store_versioned_schemas(:party),
      party_theme: 'Mystery Party'
    )

    assert_equal 'Mystery Party', record.party_theme
    assert_nil record.balloon_count

    # Reload and verify
    reloaded_record = klass.find(record.id)
    assert_equal 'Mystery Party', reloaded_record.party_theme
    assert_nil reloaded_record.balloon_count
  end

  def test_setting_store_attributes_to_nil
    # Create a record with store values
    record = klass.create!(
      store_versioned_schema: structured_store_versioned_schemas(:party),
      party_theme: 'Garden Party',
      balloon_count: 40
    )

    # Update attributes to nil
    record.party_theme = nil
    record.balloon_count = nil
    record.save!

    # Reload and verify nil values
    reloaded_record = klass.find(record.id)
    assert_nil reloaded_record.party_theme
    assert_nil reloaded_record.balloon_count
  end
end
