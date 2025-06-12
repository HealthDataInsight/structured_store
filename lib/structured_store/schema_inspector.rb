require 'json_schemer'

module StructuredStore
  # This class inspects a JSON Schema and provides methods to retrieve
  # information about properties, such as their type and structure.
  #
  # It allows us to abstract away the implementation details of JSONSchemer
  # and provides a clean interface for working with JSON Schemas.
  class SchemaInspector
    def initialize(schema_hash)
      @original_schema = schema_hash
    end

    def valid_schema?
      JSONSchemer.draft201909.valid?(@original_schema)
    rescue JSON::ParserError
      false
    end

    private

    def schemer
      @schemer ||= JSONSchemer.schema(@original_schema)
    end
  end
end
