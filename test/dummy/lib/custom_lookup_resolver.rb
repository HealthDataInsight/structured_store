# frozen_string_literal: true

# This class is an example of a custom lookup resolver for structured store.
# It resolves references to a lookup classes, allowing dynamic attribute creation
# and providing options for selection in forms.
#
# The example reference format is 'external://custom_lookup/<lookup_class_name>'.
# Lookup classes implements a method `all_current_lookups` that returns a relation
# (or array) of all the current lookups, in the order that you want them displayed.
# If your lookup classes have a different method for retrieving lookups, you can
# change the `options_array` method in the resolver in your implementation.
class CustomLookupResolver < StructuredStore::RefResolvers::Base
  def self.matching_ref_pattern
    %r{\Aexternal://custom_lookup/}
  end

  # Defines the rails attribute(s) on the given singleton class
  #
  # @return [Proc] a lambda that defines the attribute on the singleton class
  # @raise [RuntimeError] if the property type is unsupported
  def define_attribute
    # You could hard-code the type if it were always the same,
    # but it makes the JSON schema more declarative
    type = json_property_schema['type']

    unless %w[boolean integer string].include?(type)
      raise "Unsupported attribute type: #{type.inspect} for property '#{property_name}'"
    end

    # Define the attribute on the singleton class of the object
    lambda do |object|
      object.singleton_class.attribute(property_name, type.to_sym)
    end
  end

  # Returns a two dimensional array of options from the 'enum' property definition
  # Each element contains a duplicate of the enum option for both the label and value
  #
  # @return [Array<Array>] Array of arrays containing id, value option pairs
  def options_array
    klass_name = ref_string.sub('external://custom_lookup/', '')
    klass = klass_name.camelize.constantize

    # A complete implementation would check if the class is a lookup class
    # For example, you might check if it includes a specific module or inherits from a base class
    # raise(SecurityError, 'Not a lookup class') unless klass.ancestors.include?(...)

    klass.all_current_lookups.map do |lookup|
      [lookup.id, lookup.label]
    end
  end
end
