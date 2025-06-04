require 'structured_store/version'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem

# Avoid loading default resolvers by default
loader.ignore("#{__dir__}/structured_store/ref_resolvers/defaults.rb")

loader.setup

require 'structured_store/engine'
require 'structured_store/generators/install_generator' if defined?(Rails::Generators)
require 'structured_store/ref_resolvers/registry'

# This module serves as a namespace for the StructuredStore gem
module StructuredStore
  # Your code goes here...
end
