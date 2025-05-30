# This class demostrates using the StructuredStore to manage properties stored in a JSON field
class StoreRecord < ApplicationRecord
  include StructuredStore::Storable
end
