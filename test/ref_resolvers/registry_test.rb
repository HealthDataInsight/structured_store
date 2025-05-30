require 'test_helper'
# require 'ndr_import/file/registry'

module StructuredStore
  module RefResolvers
    class PotatoResolver < Base
      def resolve
        # Do nothing, it's a potato
      end
    end

    # Registry file handler tests
    class RegistryTest < ActiveSupport::TestCase
      test 'Registry.resolvers' do
        assert_instance_of Hash, Registry.resolvers
        assert_equal [
          DefinitionsResolver
        ],
                     Registry.resolvers.keys.sort_by(&:name)
      end

      test 'registering and unregistering a resolver' do
        assert_equal [DefinitionsResolver], Registry.resolvers.keys

        Registry.register(PotatoResolver, %r{^#/potato/})

        assert_equal [
          DefinitionsResolver,
          PotatoResolver
        ],
                     Registry.resolvers.keys.sort_by(&:name)

        Registry.unregister(PotatoResolver)

        assert_equal [
          DefinitionsResolver
        ],
                     Registry.resolvers.keys.sort_by(&:name)
      end

      test 'should fail to match unknown $ref' do
        exception = assert_raises(RuntimeError) do
          StructuredStore::RefResolvers::Registry.matching_resolver({}, nil, '#/foo/bar')
        end

        assert_equal 'Error: No matching $ref resolver pattern for "#/foo/bar"', exception.message
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

        resolver = Registry.matching_resolver(schema, 'foo', '#/definitions/foo')
        assert_instance_of DefinitionsResolver, resolver
      end
    end
  end
end
