class BinaryStoreRecord < ApplicationRecord
  include StructuredStore::Storable

  store :store, coder: JSON
  structured_store :store
end
