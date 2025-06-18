module StructuredStore
  # This module is included in models that need to be stored in a structured way.
  # It provides the necessary methods and attributes for structured storage.
  # The `storeable_attributes` method defines the attributes that will be stored.
  # The `to_s` method is overridden to return the name of the object or the default string representation.
  module Storable
    extend ActiveSupport::Concern

    included do
      after_initialize :define_store_accessors!

      belongs_to :versioned_schema, # rubocop:disable Rails/InverseOf
                 class_name: 'StructuredStore::VersionedSchema',
                 foreign_key: 'structured_store_versioned_schema_id'

      delegate :json_schema, to: :versioned_schema
    end

    # Dynamically define accessors for the properties defined in the
    # JSON schema that this record has.
    #
    # This method is run automatically as an `after_initialize` callback, but can be called at
    # any time for debugging and testing purposes.
    #
    # It skips defining the accessors if there is insufficient information to do so.
    def define_store_accessors!
      return unless sufficient_info_to_define_store_accessors?

      singleton_class.store_accessor(:store, json_schema_properties.keys)

      property_resolvers.each_value do |resolver|
        resolver.define_attribute.call(self)
      end
    end

    # Returns an array of property resolvers for each property in the JSON schema.
    # The resolvers are responsible for handling references and defining attributes
    # for each property defined in the schema.
    #
    # @return [Array<StructuredStore::RefResolvers::Base>] Array of resolver instances
    def property_resolvers
      @property_resolvers ||= json_schema_properties.keys.index_with do |property_name|
        StructuredStore::RefResolvers::Registry.matching_resolver(schema_inspector,
                                                                  property_name)
      end
    end

    private

    # Returns a SchemaInspector instance for the current JSON schema.
    def schema_inspector
      @schema_inspector ||= StructuredStore::SchemaInspector.new(json_schema)
    end

    # Retrieves the properties from the JSON schema
    #
    # @return [Hash] a hash containing the properties defined in the JSON schema,
    #                or an empty hash if no properties exist
    def json_schema_properties
      json_schema.fetch('properties', {})
    end

    # Returns true if there is sufficient information to define accessors for this audit_store,
    # and false otherwise.
    #
    # The JSON schema must be defined, containing property definitions.
    def sufficient_info_to_define_store_accessors?
      if json_schema.nil?
        Rails.logger.info('This storable instance has no JSON schema')
        return false
      end

      unless json_schema_properties.is_a?(Hash)
        Rails.logger.warn 'The JSON schema for this storable instance does not contain ' \
                          "a valid 'properties' hash: #{json_schema_properties.inspect}"
        return false
      end

      true
    end
  end
end
