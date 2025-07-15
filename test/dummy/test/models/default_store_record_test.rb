require_relative '../../../test_helper'
require_relative '../helpers/store_accessor_test_helper'

# This tests the DefaultStoreRecord model
class DefaultStoreRecordTest < ActiveSupport::TestCase
  include StoreAccessorTestHelper

  private

  def klass
    ::DefaultStoreRecord
  end
end
