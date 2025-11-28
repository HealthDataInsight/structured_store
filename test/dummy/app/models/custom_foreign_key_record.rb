# frozen_string_literal: true

# Example record demonstrating custom foreign_key option in structured_store
class CustomForeignKeyRecord < ApplicationRecord
  include StructuredStore::Storable

  # Using a custom foreign key instead of the default
  structured_store :preferences, foreign_key: 'my_custom_schemaid'
end
