# This class demonstrates using the StructuredStore to manage properties stored in a JSON field
class DefaultStoreRecord < ApplicationRecord
  include StructuredStore::Storable

  # No structured_store calls needed!
  # Automatically gets 'store' column with 'store_versioned_schema' association

  # Returns a memoized instance of ChronicDateRangeConverter used for converting date ranges stored as a hash in the StructuredStore JSON field.
  # Other date range converters can be used.
  #
  # @return [StructuredStore::Converters::ChronicDateRangeConverter] The date range converter instance
  def date_range_converter
    @date_range_converter ||= StructuredStore::Converters::ChronicDateRangeConverter.new
  end
end
