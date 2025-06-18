require 'test_helper'

module StructuredStore
  module RefResolvers
    class PotatoResolver < Base
      def self.matching_ref_pattern
        %r{\A#/potato/}
      end
    end

    # Registry file handler tests
    class RegistryTest < ActiveSupport::TestCase
      test 'Registry.resolvers' do
        assert_instance_of Hash, Registry.resolvers
        assert_includes Registry.resolvers.keys, DefinitionsResolver
      end

      test 'registering and unregistering a resolver' do
        assert_not_includes Registry.resolvers.keys, PotatoResolver

        PotatoResolver.register

        assert_includes Registry.resolvers.keys, PotatoResolver

        PotatoResolver.unregister

        assert_not_includes Registry.resolvers.keys, PotatoResolver
      end

      test 'should fail to match unknown $ref' do
        schema = {
          '$schema' => 'http://json-schema.org/draft/2019-09/schema#',
          'type' => 'object',
          'properties' => {
            'foo' => {
              '$ref' => '#/unknown/ref'
            }
          }
        }

        schema_inspector = StructuredStore::SchemaInspector.new(schema)
        exception = assert_raises(RuntimeError) do
          Registry.matching_resolver(schema_inspector, 'foo')
        end

        assert_equal 'Error: No matching $ref resolver pattern for "#/unknown/ref"', exception.message
      end

      test 'matching_resolver' do
        schema = {
          '$schema' => 'http://json-schema.org/draft/2019-09/schema#',
          'type' => 'object',
          'definitions' => {
            'foo' => {
              'type' => 'string',
              'description' => 'A foo property'
            }
          },
          'properties' => {
            'foo' => {
              '$ref' => '#/definitions/foo'
            }
          }
        }

        schema_inspector = StructuredStore::SchemaInspector.new(schema)
        resolver = Registry.matching_resolver(schema_inspector, 'foo')
        assert_instance_of DefinitionsResolver, resolver
      end
    end
  end
end
