require 'json_schemer'

# This Rails validator checks that an attribute is either a valid JSON schema
# or that it complies with a given schema.
class JsonSchemaValidator < ActiveModel::EachValidator
  NAMED_SCHEMA_VERSIONS = %i[draft201909 draft202012 draft4 draft6 draft7 openapi30 openapi31].freeze

  def validate_each(record, attribute, value)
    # Convert value to hash if it's a string
    json_data = value.is_a?(String) ? JSON.parse(value) : value

    # Get the schema from options, evaluating lambda if provided
    schema = resolve_schema(record, attribute, value)

    # Initialize JSONSchemer with proper handling based on schema type
    schemer = json_schemer(schema)

    # Collect validation errors
    validation_errors = schemer.validate(json_data).to_a

    # Convert JSON schema errors to Rails ActiveModel validation errors
    add_rails_errors_from(validation_errors, record) if options[:convert_to_rails_errors]

    # Add errors to the record using json_schemer's built-in I18n support
    validation_errors.each do |error|
      record.errors.add(attribute, error['error'])
    end
  rescue JSON::ParserError
    record.errors.add(attribute, :invalid_json)
  end

  private

  # Resolves the schema from options, evaluating lambda if provided.
  #
  # If the schema option is a lambda, it will be called with the record,
  # attribute, and value as arguments.
  def resolve_schema(record, attribute, value)
    schema = options[:schema] || options

    if schema.respond_to?(:call)
      schema.call(record, attribute, value)
    else
      schema
    end
  end

  def add_rails_errors_from(validation_errors, record)
    validation_errors.each do |error|
      if RailsErrorMapper.new(error, record).call
        validation_errors.delete error
      end
    end
  end

  # Converts given schema to a JSONSchemer::Schema object.
  #
  # Accepts either a symbol referencing a known schema (e.g. :draft7), a string
  # or hash representing a schema, or a JSONSchemer::Schema object directly.
  #
  # Raises an ArgumentError if schema is in an unsupported format.
  def json_schemer(schema)
    case schema
    when *NAMED_SCHEMA_VERSIONS
      JSONSchemer.send(schema)
    when String, Hash
      JSONSchemer.schema(schema)
    when JSONSchemer::Schema
      schema
    else
      raise ArgumentError, "Invalid schema format: #{schema.class}"
    end
  end
end
