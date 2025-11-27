# frozen_string_literal: true

# Example record demonstrating custom primary_key and class_name options in structured_store
class CustomPrimaryKeyRecord < ApplicationRecord
  include StructuredStore::Storable

  # Using a custom primary key and class name
  structured_store :settings,
                   schema_name: 'custom_schema',
                   class_name: 'CustomSchema',
                   foreign_key: 'custom_schema_key',
                   primary_key: 'schema_key'
end
