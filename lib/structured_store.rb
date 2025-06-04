require 'structured_store/version'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup

require 'structured_store/engine'

# This module serves as a namespace for the StructuredStore gem
module StructuredStore
  # Your code goes here...
end
