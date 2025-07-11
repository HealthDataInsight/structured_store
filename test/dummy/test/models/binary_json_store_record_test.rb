require_relative '../../../test_helper'
require_relative '../helpers/store_accessor_test_helper'

class BinaryJsonStoreRecordTest < ActiveSupport::TestCase
  include StoreAccessorTestHelper

  private

  def klass
    ::BinaryJsonStoreRecord
  end
end
