# frozen_string_literal: true

require 'structured_store/ref_resolvers/defaults'
require 'test_helper'
require_relative '../helpers/ref_resolver_test_helper'

module StructuredStore
  module RefResolvers
    # This class tests the BlankRefResolver within a structured store record.
    class BlankRefResolverTest < ActiveSupport::TestCase
      include RefResolverTestHelper

      test 'define_attribute with no attribute' do
        schema = {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'properties' => {}
        }

        store_record = build_store_record(schema)

        # Ensure the structure store attribute is not defined
        assert_not_respond_to store_record, :foo
        assert_not_respond_to store_record, :foo=
      end

      test 'define_attribute with string attribute' do
        schema = {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'properties' => {
            'foo' => {
              'type' => 'string',
              'description' => 'A foo property'
            }
          }
        }

        assert_foo_string_accessor(schema)
      end

      test 'define_attribute with untested attribute type' do
        schema = {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'properties' => {
            'foo' => {
              'type' => 'object'
            }
          }
        }

        assert_unsupported_foo_type_raises(schema)
      end
    end
  end
end
