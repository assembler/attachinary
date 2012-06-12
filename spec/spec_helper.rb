# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require 'rspec/rails'
require 'factory_girl'
require 'valid_attribute'
require 'capybara/rspec'
require 'webmock/rspec'

ENGINE_RAILS_ROOT = File.join(File.dirname(__FILE__), '../')

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

require 'factories'
# FactoryGirl.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
# FactoryGirl.find_definitions

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.use_transactional_fixtures = true
  config.include FactoryGirl::Syntax::Methods
  #config.include Attachinary::Engine.routes.url_helpers, type: :request

  config.before(:each) do
    WebMock.disable_net_connect! allow_localhost: true
  end
end

# Make it so Selenium (out of thread) tests can work with transactional fixtures
# REF http://opinionated-programmer.com/2011/02/capybara-and-selenium-with-rspec-and-rails-3/#comment-220
ActiveRecord::ConnectionAdapters::ConnectionPool.class_eval do
  def current_connection_id
    # Thread.current.object_id
    Thread.main.object_id
  end
end
