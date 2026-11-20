# frozen_string_literal: true

require 'structured_store/ref_resolvers/defaults'
require 'test_helper'
require_relative '../helpers/ref_resolver_test_helper'

module StructuredStore
  module RefResolvers
    # This class tests the DefinitionsResolver within a structured store record.
    class DefinitionsResolverTest < ActiveSupport::TestCase
      include RefResolverTestHelper

      test 'define_attribute with string attribute' do
        schema = {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'definitions' => {
            'foo_lookup' => {
              'type' => 'string',
              'description' => 'A foo property'
            }
          },
          'properties' => {
            'foo' => {
              '$ref': '#/definitions/foo_lookup'
            }
          }
        }

        assert_foo_string_accessor(schema)
      end

      test 'define_attribute with untested attribute type' do
        schema = {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'definitions' => {
            'foo_lookup' => {
              'type' => 'object'
            }
          },
          'properties' => {
            'foo' => {
              '$ref' => '#/definitions/foo_lookup'
            }
          }
        }

        assert_unsupported_foo_type_raises(schema)
      end
    end
  end
end
