module StructuredStore
  # This module is included in models that need to be stored in a structured way.
  # It provides the necessary methods and attributes for structured storage.
  #
  # To use this module, include it in your model and call `structured_store` for each
  # store column you want to configure. Each call will create a belongs_to association
  # to a VersionedSchema and define helper methods for accessing the JSON schema.
  #
  # @example Basic usage
  #   class User < ApplicationRecord
  #     include StructuredStore::Storable
  #
  #     structured_store :preferences
  #     structured_store :metadata
  #   end
  #
  # @example Custom schema name
  #   class Product < ApplicationRecord
  #     include StructuredStore::Storable
  #
  #     structured_store :configuration, schema_name: 'product_config_schema'
  #   end
  module Storable
    extend ActiveSupport::Concern

    included do
      after_initialize :define_all_store_accessors!

      class_attribute :_structured_store_configurations, default: [
        {
          column_name: 'store',
          schema_name: 'store_versioned_schema',
          foreign_key: 'structured_store_store_versioned_schema_id'
        }
      ]

      belongs_to :versioned_schema, # rubocop:disable Rails/InverseOf
                 class_name: 'StructuredStore::VersionedSchema',
                 foreign_key: 'structured_store_versioned_schema_id'

      delegate :json_schema, to: :versioned_schema
    end

    class_methods do
      # Configures the store column name
      #
      # @param column_name [String, Symbol] The name of the store column
      # @param schema_name [String, Symbol, nil] Optional schema name for the association
      #   If not provided, defaults to "#{column_name}_versioned_schema"
      #
      # @example
      #   structured_store :custom_store
      #   structured_store 'metadata', schema_name: 'custom_schema'
      def structured_store(column_name, schema_name: nil)
        column_name = column_name.to_s
        schema_name ||= "#{column_name}_versioned_schema"
        schema_name = schema_name.to_s

        # Add configuration for this column
        self._structured_store_configurations = _structured_store_configurations + [{
          column_name: column_name,
          schema_name: schema_name,
          foreign_key: "structured_store_#{schema_name}_id"
        }]
      end
    end

    # Dynamically define accessors for the properties defined in the
    # JSON schema for this specific store column.
    #
    # This method is run automatically as an `after_initialize` callback, but can be called at
    # any time for debugging and testing purposes.
    #
    # It skips defining the accessors if there is insufficient information to do so.
    #
    # @param column_name [String] The name of the store column
    def define_store_accessors_for_column(column_name)
      return unless sufficient_info_to_define_store_accessors?(column_name)

      singleton_class.store_accessor(column_name.to_sym, json_schema_properties(column_name).keys)

      property_resolvers(column_name).each_value do |resolver|
        resolver.define_attribute.call(self)
      end
    end

    # Returns an array of property resolvers for each property in the JSON schema.
    # The resolvers are responsible for handling references and defining attributes
    # for each property defined in the schema.
    #
    # @param column_name [String] The name of the store column
    # @return [Hash<String, StructuredStore::RefResolvers::Base>] Hash of resolver instances
    def property_resolvers(column_name)
      return {} if column_name.nil?

      @property_resolvers ||= {}
      @property_resolvers[column_name] ||= json_schema_properties(column_name).keys.index_with do |property_name|
        StructuredStore::RefResolvers::Registry.matching_resolver(schema_inspector(column_name),
                                                                  property_name)
      end
    end

    private

    # Returns a SchemaInspector instance for the specified store column's JSON schema.
    #
    # @param column_name [String] The name of the store column
    def schema_inspector(column_name)
      return nil if column_name.nil?

      @schema_inspectors ||= {}
      @schema_inspectors[column_name] ||= StructuredStore::SchemaInspector.new(json_schema_for_column(column_name))
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
