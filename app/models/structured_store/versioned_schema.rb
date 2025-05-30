# frozen_string_literal: true

require 'json'

module StructuredStore
  # This model stores individual versions of each structured store schema
  class VersionedSchema < ApplicationRecord
    # TODO: More JSON schema validations:
    # - none of the properties is an object (preserving a flat structure)
    # - additionalProperties must be false
    # - check all required properties are defined in properties
    validates :json_schema, json_schema: { allow_blank: true, schema: :draft201909 }
    validates :name, presence: true, uniqueness: { scope: :version, case_sensitive: true }
    validates :version, presence: true, format: { with: Gem::Version::ANCHORED_VERSION_PATTERN }

    store_accessor :json_schema, :definitions, :properties

    def self.table_name_prefix
      'structured_store_'
    end

    def self.latest(name)
      schemas = where(name: name)

      # Return nil if no schemas with this name exist
      return nil if schemas.empty?

      # Sort by version using gem_version and return the last one (highest version)
      schemas.max_by(&:gem_version)
    end

    def json_schema=(json)
      case json
      when String
        super(JSON.parse(json))
      else
        super
      end
    end

    def formatted_json_schema
      return nil if json_schema.nil?

      JSON.pretty_generate(json_schema)
    end

    def gem_version
      Gem::Version.new(version)
    end

    # Returns the lookup options for a given lookup.
    def lookup_options(lookup)
      definition = definitions[lookup.to_s]

      raise "No definition for #{lookup}" if definition.nil?

      definition['enum'] || []
    end

    # TODO: Do we still need this?
    def field_options(field)
      definition = full_property_definition(field)

      definition['enum']
    end

    # Returns the full property definition for a given field.
    # This includes the local definition if the property references one.
    def full_property_definition(field)
      hash = properties[field.to_s]
      definition_name = local_definition_name(field)
      local_definition = definitions[definition_name]

      hash = hash.merge(local_definition) unless local_definition.nil?
      hash
    end

    # Returns the local definition name for a given field.
    # It raises an error if the field has a reference that is not local.
    def local_definition_name(field)
      hash = properties[field.to_s]

      raise "No property definition for #{field}" if hash.nil?

      ref = hash['$ref']

      return nil if ref.nil?
      raise "Not a local reference in $ref: #{ref}" unless ref.start_with?('#/definitions/')

      ref.sub('#/definitions/', '')
    end
  end
end
