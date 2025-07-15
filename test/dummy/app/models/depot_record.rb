# frozen_string_literal: true

# Example record with only a single custom-named store column
class DepotRecord < ApplicationRecord
  include StructuredStore::Storable

  # Only one store column called 'depot'
  structured_store :depot
end
