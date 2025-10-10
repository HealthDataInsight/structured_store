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
        def register(klass)
          @resolvers ||= {}
          @resolvers[klass] = klass.matching_ref_pattern
        end

        # Unregisters a resolver class from the registry
        #
        # @param klass [Class] The resolver class to remove from the registry
        # @return [Class, nil] The removed resolver class or nil if not found
        def unregister(klass)
          @resolvers.delete(klass)
        end

        # Returns a resolver instance for the given schema property reference
        #
        # @param [SchemaInspector] schema_inspector The JSON schema inspector
        # @param [String, Symbol] property_name The name of the property containing the reference
        # @param [Hash] context Optional context hash (default: {})
        # @return [RefResolver] An instance of the appropriate resolver class for the reference
        # @raise [RuntimeError] If no matching resolver can be found for the reference
        def matching_resolver(schema_inspector, property_name, context = {})
          property_schema = schema_inspector.property_schema(property_name)
          ref_string = property_schema['$ref'].to_s

          resolver_for_schema_hash(property_schema, schema_inspector, property_name, ref_string, context)
        end

        # Returns a resolver instance for a schema hash (e.g., array items)
        # Direct method that doesn't require looking up properties
        #
        # @param [Hash] schema_hash The schema hash (with potential $ref)
        # @param [SchemaInspector] parent_schema Parent schema for definition lookups
        # @param [String] property_name The property name for error messages
        # @param [String] ref_string The $ref string
        # @param [Hash] context Optional context hash (default: {})
        # @return [RefResolver] An instance of the appropriate resolver class
        def resolver_for_schema_hash(schema_hash, parent_schema, property_name, ref_string, context = {})
          klass = klass_factory(ref_string)
          klass.new(schema_hash, parent_schema, property_name, ref_string, context)
        end

        private

        # Creates a new resolver instance based on the provided reference string
        #
        # @param ref_string [String] The $ref string to resolve
        # @return [Object] An instance of the matching resolver class or NoRefResolver
        # @raise [RuntimeError] If no matching resolver class is found for the reference string
        def klass_factory(ref_string)
          # Find the first registered resolver class that matches the ref_string
          klass = resolvers.find { |_, regexp| ref_string.to_s.match?(regexp) }&.then { |(klass, _)| klass }
          return klass if klass

          raise "Error: No matching $ref resolver pattern for #{ref_string.inspect}"
        end
      end
    end
  end
end
