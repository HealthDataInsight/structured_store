module StructuredStore
  # This module is included in models that need to be stored in a structured way.
  # It provides the necessary methods and attributes for structured storage.
  # The `storeable_attributes` method defines the attributes that will be stored.
  # The `to_s` method is overridden to return the name of the object or the default string representation.
  module Storable
    extend ActiveSupport::Concern

    included do
      after_initialize :define_store_accessors!

      belongs_to :versioned_schema,
                 class_name: 'StructuredStore::VersionedSchema',
                 foreign_key: 'structured_store_versioned_schema_id'

      delegate :full_property_definition, :field_options, :lookup_options, to: :versioned_schema
    end

    # Dynamically define accessors for the properties defined in the
    # `versioned_schema` that this record belongs to.
    #
    # This method is run automatically as an `after_initialize` callback, but can be called at
    # any time for debugging and testing purposes.
    #
    # It skips defining the accessors if there is insufficient information to do so.
    def define_store_accessors!
      return unless sufficient_info_to_define_store_accessors?

      singleton_class.store_accessor(:store, versioned_schema.properties.keys)

      versioned_schema.properties.each do |property_name, property_definition|
        if property_definition['$ref']
          # Other resolvers will handle the $ref properties.
          options = full_property_definition(property_name)
          if options['$ref'] == '#/definitions/daterange'
            singleton_class.attribute("#{property_name}1", :string)
            singleton_class.attribute("#{property_name}2", :string)
            singleton_class.attribute(property_name, :string) # temp?
          else
          end
        else
          resolver = StructuredStore::RefResolvers::Registry.matching_resolver(versioned_schema.json_schema,
                                                                               property_name, property_definition['$ref'])
          resolver.define_attribute.call(self)
        end
      end
    end

    private

    # Returns true if there is sufficient information to define accessors for this audit_store,
    # and false otherwise.
    #
    # The versioned_schema must be defined, with a JSON schema containing properties definitions.
    def sufficient_info_to_define_store_accessors?
      if versioned_schema.nil?
        Rails.logger.info("This storable instance has no versioned_schema")
        return false
      end

      unless versioned_schema.properties.is_a?(Hash)
        Rails.logger.warn("No JSON schema is defined for #{versioned_schema.name} (#{versioned_schema.version})")
        return false
      end

      true
    end
  end
end
