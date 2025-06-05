# frozen_string_literal: true

require 'structured_store/ref_resolvers/defaults'
require 'test_helper'

module StructuredStore
  module RefResolvers
    # This class tests the BlankRefResolver.
    class BlankRefResolverTest < ActiveSupport::TestCase
      test 'matching_ref_pattern' do
        assert_match BlankRefResolver.matching_ref_pattern, ''

        assert_no_match BlankRefResolver.matching_ref_pattern, '#/definitions/foo'
        assert_no_match BlankRefResolver.matching_ref_pattern, 'external://custom_lookup/yes_no_unknown'
        assert_no_match BlankRefResolver.matching_ref_pattern, 'external://structured_store/json_date_range/'
      end

      test 'matching_resolver' do
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

        resolver = Registry.matching_resolver(schema, 'foo')
        assert_instance_of BlankRefResolver, resolver
      end

      test 'options_array' do
        schema = {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'properties' => {
            'foo' => {
              'type' => 'string',
              'enum' => %w[option1 option2 option3]
            }
          },
          'additionalProperties' => false
        }

        resolver = Registry.matching_resolver(schema, 'foo')
        assert_instance_of BlankRefResolver, resolver

        assert_equal [%w[option1 option1], %w[option2 option2], %w[option3 option3]], resolver.options_array
      end
    end
  end
end
