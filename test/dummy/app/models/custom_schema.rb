# frozen_string_literal: true

# Custom schema model for testing non-conventional primary keys
# This model uses 'schema_key' instead of 'id' as its primary key
class CustomSchema < ApplicationRecord
  self.table_name = 'custom_schemas'
  self.primary_key = 'schema_key'
end
