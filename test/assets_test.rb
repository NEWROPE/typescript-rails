require File.join(File.dirname(__FILE__), 'test_helper.rb')
require 'typescript-rails'

require 'action_controller/railtie'
require 'sprockets/railtie'


class AssetsTest < ActiveSupport::TestCase
  include Minitest::PowerAssert::Assertions

  def setup
    FileUtils.mkdir_p tmp_path

    @app = Class.new(Rails::Application)

    @app.config.eager_load = false
    @app.config.active_support.deprecation = :stderr
    @app.config.assets.configure do |env|
      env.cache = ActiveSupport::Cache.lookup_store(:memory_store)
    end
    @app.config.assets.paths << "#{File.dirname(__FILE__)}/fixtures/assets"
    @app.paths['log'] = "#{tmp_path}/log/test.log"
    @app.initialize!
  end

  def teardown
    FileUtils.rm_rf tmp_path
  end

  def tmp_path
    "#{File.dirname(__FILE__)}/tmp"
  end

  def assets
    @app.assets
  end

  # Run all tests in one block to avoid error from calling @app.initialize! multiple times
  test 'generates assets successfully' do
    # typescript.js is included in Sprockets environment
    assert { assets['typescript'].filename.to_s.end_with?('/lib/assets/javascripts/typescript.js.erb') }
    assert { assets['typescript'].source.include?('var ts;') }

    # 'assets .js.ts is compiled from TypeScript to JavaScript'
    assert { assets['javascripts/hello.js'].present? }
    assert { assets['javascripts/hello.js'].source.include?('var log_to_console = function (x) {') }
    assert { assets['javascripts/hello.js'].source.include?('var s = "Hello, world!";') }
  end
end
