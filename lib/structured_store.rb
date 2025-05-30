require "structured_store/version"

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.setup

require 'structured_store/engine'
require 'structured_store/generators/install_generator' if defined?(Rails::Generators)
require 'structured_store/ref_resolvers/registry'

module StructuredStore
  # Your code goes here...
end
