# frozen_string_literal: true

# Regression model: exercises structured_store when the column is NOT called "store".
# Reproduces the bug where JsonDateRangeResolver hardcoded the `store` accessor name.
class AuditStoreRecord < ApplicationRecord
  include StructuredStore::Storable

  structured_store :audit_store

  # Returns a memoized ChronicDateRangeConverter for use by JsonDateRangeResolver.
  #
  # @return [StructuredStore::Converters::ChronicDateRangeConverter]
  def date_range_converter
    @date_range_converter ||= StructuredStore::Converters::ChronicDateRangeConverter.new
  end
end
