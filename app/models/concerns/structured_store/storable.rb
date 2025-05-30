module StructuredStore
  # This module is included in models that need to be stored in a structured way.
  # It provides the necessary methods and attributes for structured storage.
  # The `storeable_attributes` method defines the attributes that will be stored.
  # The `to_s` method is overridden to return the name of the object or the default string representation.
  module Storable
    extend ActiveSupport::Concern

    included do
      after_initialize :define_store_accessors!
    end

    # Dynamically define accessors for the properties defined in the
    # `versioned_schema` that this `StructuredStore::Record` belongs to.
    #
    # This method is run automatically as an `after_initialize` callback, but can be called at
    # any time for debugging and testing purposes.
    #
    # It skips defining the accessors if there is insufficent information to do so.
    def define_store_accessors!
      return unless sufficient_info_to_define_store_accessors?

      singleton_class.store_accessor(:store, versioned_schema.properties.keys)

      versioned_schema.properties.each_key do |property|
        options = full_property_definition(property)
        type = options['type']
        case type
        when 'boolean', 'integer', 'string'
          singleton_class.attribute(property, type.to_sym)
        else
          if options['$ref'] == '#/definitions/daterange'
            singleton_class.attribute("#{property}1", :string)
            singleton_class.attribute("#{property}2", :string)
            singleton_class.attribute(property, :string) # temp?
          else
            raise "Untested JSON property type: #{type.inspect} for #{property}"
          end
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
        Rails.logger.info('This audit_store has no versioned_schema')
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
