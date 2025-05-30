# frozen_string_literal: true

module StructuredStore
  module RefResolvers
    # This is the registry for JSON Schema $ref resolvers.
    module Registry
      class << self
        # Returns the Hash of registered resolvers
        # If no resolvers have been registered, returns an empty Hash
        # @return [Hash] Registered resolvers
        def resolvers
          @resolvers || {}
        end

        # Registers a resolver class with a specific regular expression pattern.
        #
        # @param klass [Class] The resolver class to register.
        # @param regexp [Regexp] The regular expression pattern to match against references.
        def register(klass, regexp)
          @resolvers ||= {}
          @resolvers[klass] = regexp
        end

        # Unregisters a resolver class from the registry
        #
        # @param klass [Class] The resolver class to remove from the registry
        # @return [Class, nil] The removed resolver class or nil if not found
        def unregister(klass)
          @resolvers.delete(klass)
        end

        def matching_resolver(schema, property_name, ref_string, context = {})
          klass_factory(ref_string).new(schema, property_name, ref_string, context)
        end

        private

        # Creates a new resolver instance based on the provided reference string
        #
        # @param ref_string [String] The reference string to resolve
        # @param context [Hash] Optional context for the resolver
        # @return [Object] A new instance of the matching resolver class or UnregisteredRef
        def klass_factory(ref_string)
          # Find the first registered resolver class that matches the ref_string
          klass = resolvers.find { |_, regexp| ref_string.match?(regexp) }&.then { |(klass, _)| klass }
          return klass if klass

          raise "Error: No matching $ref resolver pattern for #{ref_string.inspect}"
        end
      end
    end
  end
end

require_relative 'definitions_resolver'
