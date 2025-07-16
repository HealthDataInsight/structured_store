class BinaryJsonStoreRecord < ApplicationRecord
  include StructuredStore::Storable

  structured_store :store
end
