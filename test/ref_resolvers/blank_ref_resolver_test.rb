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

        schema_inspector = StructuredStore::SchemaInspector.new(schema)
        resolver = Registry.matching_resolver(schema_inspector, 'foo')
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

        schema_inspector = StructuredStore::SchemaInspector.new(schema)
        resolver = Registry.matching_resolver(schema_inspector, 'foo')
        assert_instance_of BlankRefResolver, resolver

        assert_equal [%w[option1 option1], %w[option2 option2], %w[option3 option3]], resolver.options_array
      end

      test 'array with direct type items (string)' do
        schema = {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'properties' => {
            'tags' => {
              'type' => 'array',
              'items' => {
                'type' => 'string'
              }
            }
          }
        }

        versioned_schema = VersionedSchema.new(json_schema: schema)
        store_record = StoreRecord.new(store_versioned_schema: versioned_schema)

        assert_respond_to store_record, :tags
        assert_respond_to store_record, :tags=

        store_record.tags = %w[ruby rails testing]
        assert_equal %w[ruby rails testing], store_record.tags
      end

      test 'array with direct type items (integer)' do
        schema = {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'properties' => {
            'scores' => {
              'type' => 'array',
              'items' => {
                'type' => 'integer'
              }
            }
          }
        }

        versioned_schema = VersionedSchema.new(json_schema: schema)
        store_record = StoreRecord.new(store_versioned_schema: versioned_schema)

        assert_respond_to store_record, :scores
        assert_respond_to store_record, :scores=

        store_record.scores = [1, 2, 3, 4, 5]
        assert_equal [1, 2, 3, 4, 5], store_record.scores
      end

      test 'array with $ref items pointing to definition' do
        schema = {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'definitions' => {
            'stain_type' => {
              'type' => 'string',
              'enum' => %w[A B C]
            }
          },
          'properties' => {
            'stains' => {
              'type' => 'array',
              'items' => {
                '$ref' => '#/definitions/stain_type'
              }
            }
          }
        }

        versioned_schema = VersionedSchema.new(json_schema: schema)
        store_record = StoreRecord.new(store_versioned_schema: versioned_schema)

        assert_respond_to store_record, :stains
        assert_respond_to store_record, :stains=

        store_record.stains = %w[A B]
        assert_equal %w[A B], store_record.stains
      end

      test 'array with $ref items pointing to integer definition' do
        schema = {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'definitions' => {
            'score_value' => {
              'type' => 'integer'
            }
          },
          'properties' => {
            'scores' => {
              'type' => 'array',
              'items' => {
                '$ref' => '#/definitions/score_value'
              }
            }
          }
        }

        versioned_schema = VersionedSchema.new(json_schema: schema)
        store_record = StoreRecord.new(store_versioned_schema: versioned_schema)

        assert_respond_to store_record, :scores
        assert_respond_to store_record, :scores=

        store_record.scores = [10, 20, 30]
        assert_equal [10, 20, 30], store_record.scores
      end

      test 'array with $ref items - options_array' do
        schema = {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'definitions' => {
            'status' => {
              'type' => 'string',
              'enum' => %w[pending active completed]
            }
          },
          'properties' => {
            'statuses' => {
              'type' => 'array',
              'items' => {
                '$ref' => '#/definitions/status'
              }
            }
          }
        }

        versioned_schema = VersionedSchema.new(json_schema: schema)
        store_record = StoreRecord.new(store_versioned_schema: versioned_schema)

        resolver = store_record.property_resolvers('store')['statuses']
        options = resolver.options_array

        assert_equal 3, options.length
        assert_includes options, %w[pending pending]
        assert_includes options, %w[active active]
        assert_includes options, %w[completed completed]
      end

      test 'array with direct type items with enum - options_array' do
        schema = {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'properties' => {
            'priorities' => {
              'type' => 'array',
              'items' => {
                'type' => 'string',
                'enum' => %w[low medium high]
              }
            }
          }
        }

        versioned_schema = VersionedSchema.new(json_schema: schema)
        store_record = StoreRecord.new(store_versioned_schema: versioned_schema)

        resolver = store_record.property_resolvers('store')['priorities']
        options = resolver.options_array

        assert_equal 3, options.length
        assert_includes options, %w[low low]
        assert_includes options, %w[medium medium]
        assert_includes options, %w[high high]
      end

      test 'array with unsupported item type raises error' do
        schema = {
          '$schema' => 'https://json-schema.org/draft/2019-09/schema',
          'type' => 'object',
          'properties' => {
            'complex_items' => {
              'type' => 'array',
              'items' => {
                'type' => 'object'
              }
            }
          }
        }

        exception = assert_raises(RuntimeError) do
          versioned_schema = VersionedSchema.new(json_schema: schema)
          StoreRecord.new(store_versioned_schema: versioned_schema)
        end

        assert_equal 'Unsupported array item type: "object" for property \'complex_items\'', exception.message
      end
    end
  end
end
