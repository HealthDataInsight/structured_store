# This class demonstrates using the StructuredStore to manage properties stored in a JSON field
class StoreRecord < ApplicationRecord
  include StructuredStore::Storable

  structured_store :store

  # Returns a memoized instance of ChronicDateRangeConverter used for converting date ranges stored as a hash in the StructuredStore JSON field.
  # Other date range converters can be used.
  #
  # @return [StructuredStore::Converters::ChronicDateRangeConverter] The date range converter instance
  def date_range_converter
    @date_range_converter ||= StructuredStore::Converters::ChronicDateRangeConverter.new
  end
end
