require_relative '../../../test_helper'
require_relative '../helpers/store_accessor_test_helper'

class TextStoreRecordTest < ActiveSupport::TestCase
  include StoreAccessorTestHelper

  private

  def klass
    ::TextStoreRecord
  end
end
