require 'json_schemer'
require 'active_support'
require 'active_support/core_ext/hash'

module StructuredStore
  # This class inspects a JSON Schema and provides methods to retrieve
  # property and definition schemas.
  #
  # It allows us to abstract away the implementation details of JSONSchemer
  # and provides a clean interface for working with JSON Schemas.
  class SchemaInspector
    MAX_JSON_INPUT_SIZE_BYTES = 1_048_576

    def initialize(schema)
      @original_schema = schema
    end

    def valid_schema?
      JSONSchemer.draft201909.valid?(schema_hash)
    rescue ArgumentError
      false
    end

    def property_schema(property_name)
      schema_hash.dig('properties', property_name.to_s)
    end

    def definition_schema(definition_name)
      schema_hash.dig('definitions', definition_name.to_s)
    end

    private

    def safe_parse_json(json_string)
      # Ensure the schema is a valid JSON object
      if json_string.bytesize > MAX_JSON_INPUT_SIZE_BYTES
        raise ArgumentError, "Schema size exceeds maximum limit of #{MAX_JSON_INPUT_SIZE_BYTES} bytes"
      end

      JSON.parse(json_string)
    rescue JSON::ParserError
      raise ArgumentError, "Invalid JSON schema: #{json_string.inspect}"
    end

    def schema_hash
      @schema_hash =
        case @original_schema
        when Hash
          # TODO: ensure the hash is safe to use (e.g. not too large)
          @original_schema.deep_stringify_keys
        when String
          safe_parse_json(@original_schema)
        else
          raise ArgumentError, "Unsupported schema type: #{@original_schema.class}"
        end
    end
    public :schema_hash
  end
end
