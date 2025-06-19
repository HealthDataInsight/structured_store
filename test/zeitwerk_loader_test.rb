# frozen_string_literal: true

require 'test_helper'

class ZeitwerkLoaderTest < Minitest::Test
  def setup
    @root = Pathname.new(File.expand_path('..', __dir__))

    @loader = Zeitwerk::Loader.new
    @loader.tag = 'structured_store.rb'
    @loader.inflector = Zeitwerk::GemInflector.new(@root.join('lib/structured_store.rb'))
    # @loader.push_dir(@root.join('test'))
    @loader.ignore(@root.join('test/test_helper.rb'))
    @loader.setup
  end

  def teardown
    @loader.unload
  end

  def test_eager_load
    @loader.eager_load(force: true)
  rescue Zeitwerk::NameError => e
    flunk "Eager loading failed with error: #{e.message}"
  end
end
