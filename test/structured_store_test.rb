require 'test_helper'

class StructuredStoreTest < ActiveSupport::TestCase
  test 'it has a version number' do
    assert_kind_of String, StructuredStore::VERSION
    assert_match Gem::Version::ANCHORED_VERSION_PATTERN, StructuredStore::VERSION
  end
end
