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

      class_attribute :_structured_store_configurations, default: []
    end

    # Override initialize to handle store attributes after accessors are defined
    def initialize(attributes = nil)
      unless attributes.is_a?(Hash)
        super
        return
      end

      # Separate known from unknown attributes and call super, then re-assign
      known_attrs, unknown_attrs = separate_known_and_unknown_attributes(attributes)

      super(known_attrs)

      assign_attributes(unknown_attrs) if unknown_attrs.present?
    end

    private

    # Separates known attributes (columns and schema associations) from potential store attributes
    def separate_known_and_unknown_attributes(attributes)
      known_attrs = {}
      unknown_attrs = {}

      attributes.each do |key, value|
        if respond_to?(key.to_s)
          known_attrs[key] = value
        else
          unknown_attrs[key] = value
        end
      end

      [known_attrs, unknown_attrs]
    end

    public

    class_methods do
      # Configures a structured store column and creates the necessary associations.
      #
      # This method must be called explicitly for each store column you want to use.
      # It will:
      # - Add the column configuration to the internal tracking
      # - Create a belongs_to association to StructuredStore::VersionedSchema
      # - Define a helper method to access the JSON schema for this store
      #
      # @param column_name [String, Symbol] The name of the store column in your model
      # @param schema_name [String, Symbol, nil] Optional custom name for the schema association
      #   If not provided, defaults to "#{column_name}_versioned_schema"
      # @param belongs_to_options [Hash] Options to pass to the belongs_to association
      # @option belongs_to_options [String, Symbol] :foreign_key Custom foreign key for the belongs_to association
      #   If not provided, defaults to "structured_store_#{schema_name}_id"
      # @option belongs_to_options [String, Symbol] :primary_key Custom primary key for the belongs_to association
      #   If not provided, uses the default primary key of the associated model
      # @option belongs_to_options [String] :class_name Custom class name for the belongs_to association
      #   If not provided, defaults to 'StructuredStore::VersionedSchema'
      #
      # @example Simple store configuration
      #   structured_store :preferences
      #   # Creates: belongs_to :preferences_versioned_schema
      #   # Helper method: preferences_json_schema
      #
      # @example Custom schema name
      #   structured_store :config, schema_name: 'product_configuration'
      #   # Creates: belongs_to :product_configuration
      #   # Helper method: product_configuration_json_schema
      #
      # @example Custom foreign key
      #   structured_store :settings, foreign_key: 'custom_schema_id'
      #   # Creates: belongs_to with foreign_key: 'custom_schema_id'
      #
      # @example Custom primary key
      #   structured_store :settings, primary_key: 'custom_pk'
      #   # Creates: belongs_to with primary_key: 'custom_pk'
      #
      # @example Custom class name
      #   structured_store :settings, class_name: 'CustomSchema'
      #   # Creates: belongs_to with class_name: 'CustomSchema'
      def structured_store(column_name, schema_name: nil, **belongs_to_options)
        column_name = column_name.to_s
        schema_name ||= "#{column_name}_versioned_schema"
        schema_name = schema_name.to_s

        # Set defaults for belongs_to options if not provided
        belongs_to_options[:foreign_key] ||= "structured_store_#{schema_name}_id"
        belongs_to_options[:class_name] ||= 'StructuredStore::VersionedSchema'

        # Add configuration for this column
        self._structured_store_configurations = _structured_store_configurations + [{
          column_name: column_name,
          schema_name: schema_name
        }]

        # Define the belongs_to association immediately
        belongs_to schema_name.to_sym, **belongs_to_options

        # Define helper method to get schema for this specific store
        define_method "#{column_name}_json_schema" do
          send(schema_name)&.json_schema
        end
      end
    end

    # Define accessors for all configured store columns
    def define_all_store_accessors!
      _structured_store_configurations.each do |config|
        define_store_accessors_for_column(config[:column_name])
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

    # Retrieves the properties from the JSON schema for the specified store column
    #
    # @param column_name [String] The name of the store column
    # @return [Hash] a hash containing the properties defined in the JSON schema,
    #                or an empty hash if no properties exist
    def json_schema_properties(column_name)
      return {} if column_name.nil?

      json_schema_for_column(column_name).fetch('properties', {})
    end

    # Gets the JSON schema for a specific store column
    #
    # @param column_name [String] The name of the store column
    # @return [Hash] The JSON schema hash
    def json_schema_for_column(column_name)
      return {} if column_name.nil?

      send("#{column_name}_json_schema") || {}
    end

    # Returns true if there is sufficient information to define accessors for the specified store column,
    # and false otherwise.
    #
    # The JSON schema must be defined, containing property definitions.
    #
    # @param column_name [String] The name of the store column
    def sufficient_info_to_define_store_accessors?(column_name)
      return false if column_name.nil?

      schema = json_schema_for_column(column_name)
      properties = json_schema_properties(column_name)

      if schema.blank?
        Rails.logger.info("This storable instance has no JSON schema for column '#{column_name}'")
        return false
      end

      unless properties.is_a?(Hash)
        Rails.logger.warn "The JSON schema for column '#{column_name}' does not contain " \
                          "a valid 'properties' hash: #{properties.inspect}"
        return false
      end

      true
    end
  end
end
