require "structured_store/version"
require "structured_store/railtie"

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.setup

require 'structured_store/engine'

module StructuredStore
  # Your code goes here...
end
