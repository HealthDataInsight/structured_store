# frozen_string_literal: true

# Example record demonstrating multiple structured store columns
class ExampleRecord < ApplicationRecord
  include StructuredStore::Storable

  # Multiple stores for different purposes
  structured_store :store
  structured_store :metadata, schema_name: 'metadata_schema'
  structured_store :settings
end
