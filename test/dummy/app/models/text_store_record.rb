class TextStoreRecord < ApplicationRecord
  include StructuredStore::Storable

  store :store, coder: JSON
end
