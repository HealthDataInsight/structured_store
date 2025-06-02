require 'test_helper'

module StructuredStore
  module RefResolvers
    class PotatoResolver < Base
    end

    # Registry file handler tests
    class RegistryTest < ActiveSupport::TestCase
      test 'Registry.resolvers' do
        assert_instance_of Hash, Registry.resolvers
        assert_includes Registry.resolvers.keys, DefinitionsResolver
      end

      test 'registering and unregistering a resolver' do
        assert_not_includes Registry.resolvers.keys, PotatoResolver

        Registry.register(PotatoResolver, %r{\A#/potato/})

        assert_includes Registry.resolvers.keys, PotatoResolver

        Registry.unregister(PotatoResolver)

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

        exception = assert_raises(RuntimeError) do
          Registry.matching_resolver(schema, 'foo')
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

        resolver = Registry.matching_resolver(schema, 'foo')
        assert_instance_of DefinitionsResolver, resolver
      end
    end
  end
end
