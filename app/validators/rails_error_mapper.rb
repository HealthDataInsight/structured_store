# frozen_string_literal: true

# Maps JSON Schema validation errors to Rails ActiveModel validation errors.
#
# This class transforms validation errors from JSONSchemer into Rails-native
# error messages, making them compatible with ActiveModel's error reporting
# and internationalization system.
#
# @example Basic usage
#   json_error = {
#     'type' => 'minimum',
#     'data_pointer' => '/age',
#     'schema' => { 'minimum' => 18 }
#   }
#   mapper = RailsErrorMapper.new(json_error, user)
#   mapper.call # => true
#   user.errors[:age] # => ["must be greater than or equal to 18"]
#
# @example With custom error messages
#   # Configure custom messages in config/locales/json_schema_validator.en.yml
#   en:
#     errors:
#       messages:
#         invalid_email: "is not a valid email address"
class RailsErrorMapper
  attr_accessor :json_error, :record

  # Maps JSON Schema error types to Rails validation error handlers.
  # Each handler is a lambda that receives the attribute, error hash, and record,
  # then adds the appropriate Rails validation error.
  #
  # @note Handlers for schema composition, dependencies, const, and content validations
  #   are not yet implemented. See TODO comments for details.
  ERROR_MAPPINGS = {
    # Presence validation - extracts missing required fields and adds :blank errors
    'required' => lambda { |_attr, error, record|
      missing_keys = error.dig('details', 'missing_keys') || []
      missing_keys.each { |key| record.errors.add(key.to_sym, :blank) }
    },

    # Numeric range validations
    'minimum' => lambda { |attr, error, record|
      record.errors.add(attr, :greater_than_or_equal_to, count: error['schema']['minimum'])
    },
    'maximum' => lambda { |attr, error, record|
      record.errors.add(attr, :less_than_or_equal_to, count: error['schema']['maximum'])
    },
    'exclusiveMinimum' => lambda { |attr, error, record|
      record.errors.add(attr, :greater_than, count: error['schema']['exclusiveMinimum'])
    },
    'exclusiveMaximum' => lambda { |attr, error, record|
      record.errors.add(attr, :less_than, count: error['schema']['exclusiveMaximum'])
    },

    # Length/size validations for strings, arrays, and objects
    'minLength' => lambda { |attr, error, record|
      record.errors.add(attr, :too_short, count: error['schema']['minLength'])
    },
    'maxLength' => lambda { |attr, error, record|
      record.errors.add(attr, :too_long, count: error['schema']['maxLength'])
    },
    'minItems' => lambda { |attr, error, record|
      record.errors.add(attr, :too_short, count: error['schema']['minItems'])
    },
    'maxItems' => lambda { |attr, error, record|
      record.errors.add(attr, :too_long, count: error['schema']['maxItems'])
    },
    'minProperties' => lambda { |attr, error, record|
      record.errors.add(attr, :too_short, count: error['schema']['minProperties'])
    },
    'maxProperties' => lambda { |attr, error, record|
      record.errors.add(attr, :too_long, count: error['schema']['maxProperties'])
    },

    # Format validations (email, URL, UUID, date, IP address, etc.)
    'format' => lambda { |attr, error, record|
      format_type = error['schema']['format']
      error_symbol = format_error_symbol(format_type)
      record.errors.add(attr, error_symbol)
    },

    # Pattern/regex validation
    'pattern' => lambda { |attr, error, record|
      record.errors.add(attr, :invalid_format)
    },

    # Type validation (string, integer, boolean, etc.)
    'type' => lambda { |attr, error, record|
      expected_type = error['schema']['type']
      record.errors.add(attr, :invalid_type, type: expected_type)
    },

    # Enum validation - shows all values if 5 or fewer, otherwise generic message
    'enum' => lambda { |attr, error, record|
      values = error['schema']['enum']
      if values.length <= 5
        record.errors.add(attr, :enum_inclusion_short_list, value: record.send(attr), values: values.join(', '))
      else
        record.errors.add(attr, :inclusion, value: record.send(attr))
      end
    },

    # Unique items validation for arrays
    'uniqueItems' => lambda { |attr, error, record|
      record.errors.add(attr, :non_unique_items)
    },

    # Multiple of validation for numbers
    'multipleOf' => lambda { |attr, error, record|
      multiple = error['schema']['multipleOf']
      record.errors.add(attr, :not_multiple_of, multiple: multiple)
    },

    # Additional properties validation for objects
    'additionalProperties' => lambda { |attr, error, record|
      record.errors.add(attr, :unexpected_properties)
    }

    # TODO: Implement schema composition validations
    # 'oneOf' => ...
    # 'anyOf' => ...
    # 'allOf' => ...
    # 'not' => ...

    # TODO: Implement dependency validations
    # 'dependencies' => ...
    # 'dependentRequired' => ...
    # 'dependentSchemas' => ...

    # TODO: Implement content validations
    # 'contentMediaType' => ...
    # 'contentEncoding' => ...

    # TODO: Implement const validation
    # 'const' => ...
  }.freeze

  # Initializes a new RailsErrorMapper.
  #
  # @param json_error [Hash] The JSON Schema validation error from JSONSchemer
  # @param record [ActiveModel::Model] The record to add Rails validation errors to
  #
  # @example
  #   json_error = { 'type' => 'minimum', 'schema' => { 'minimum' => 0 } }
  #   mapper = RailsErrorMapper.new(json_error, user)
  def initialize(json_error, record)
    @json_error = json_error
    @record = record
  end

  # Maps the JSON Schema error to a Rails validation error and adds it to the record.
  #
  # @return [Boolean] true if the error was successfully mapped, nil if no handler exists
  #   for this error type
  #
  # @example
  #   mapper = RailsErrorMapper.new(json_error, user)
  #   if mapper.call
  #     puts "Error mapped successfully"
  #   else
  #     puts "Unknown error type: #{json_error['type']}"
  #   end
  def call
    attribute = extract_attribute_from_error
    error_type = json_error['type']
    handler = ERROR_MAPPINGS[error_type]

    return unless handler

    handler.call(attribute, json_error, record)

    true
  end

  private

  # Extracts the attribute name from the JSON Schema error's data pointer.
  #
  # The data pointer is a JSON Pointer that indicates where in the
  # JSON structure the error occurred. This method extracts the last segment
  # of the pointer to use as the Rails attribute name.
  #
  # @return [Symbol] The attribute name, or :base for root-level errors
  #
  # @example
  #   # For pointer '/user/email' returns :email
  #   # For pointer '/age' returns :age
  #   # For pointer '/' or '' returns :base
  #
  # @note Currently uses the leaf node of the pointer. For nested structures,
  #   consider whether the first segment would be more appropriate.
  def extract_attribute_from_error
    pointer = json_error['data_pointer']
    return :base if pointer.blank? || pointer == '/'

    parts = pointer.sub(%r{^/}, '').split('/')
    parts.last.to_sym
  end

  # Maps JSON Schema format types to Rails error symbols.
  #
  # @param format_type [String] The JSON Schema format type (e.g., 'email', 'uuid')
  # @return [Symbol] The corresponding Rails error symbol
  #
  # @example
  #   format_error_symbol('email') # => :invalid_email
  #   format_error_symbol('uri')   # => :invalid_url
  #   format_error_symbol('custom') # => :invalid_format
  #
  # @note Error messages for these symbols should be defined in locale files
  class << self
    def format_error_symbol(format_type)
      case format_type
      when 'email'
        :invalid_email
      when 'uri', 'url'
        :invalid_url
      when 'uuid'
        :invalid_uuid
      when 'date', 'date-time'
        :invalid_date
      when 'ipv4', 'ipv6'
        :invalid_ip
      else
        :invalid_format
      end
    end
  end
end
