# frozen_string_literal: true

require 'json'

module StructuredStore
  # This model stores individual versions of each structured store schema
  class VersionedSchema < ApplicationRecord
    MAX_JSON_INPUT_SIZE_BYTES = 1_048_576

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
        if json.bytesize > MAX_JSON_INPUT_SIZE_BYTES
          raise ArgumentError, "JSON input exceeds maximum allowed size of #{MAX_JSON_INPUT_SIZE_BYTES} bytes"
        end
        super(JSON.parse(json))
      else
        super
      end
    rescue JSON::ParserError
      # Let the validator handle the error by assigning the original string
      # This ensures the validator has access to the invalid JSON string
      # and can add an appropriate error message to the record.
      self[:json_schema] = json
    end

    def gem_version
      Gem::Version.new(version)
    end
  end
end
