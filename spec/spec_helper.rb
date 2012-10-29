# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"
ATTACHINARY_ORM = (ENV["ATTACHINARY_ORM"] || :active_record).to_sym

$:.unshift File.dirname(__FILE__)

require "dummy/config/environment.rb"
require "orm/#{ATTACHINARY_ORM}"

require 'rspec/rails'
require 'valid_attribute'
require 'capybara/rspec'

require 'factory_girl'
require 'factories'

require 'database_cleaner'

require "capybara/webkit"
Capybara.javascript_driver = :webkit


ENGINE_RAILS_ROOT = File.join(File.dirname(__FILE__), '../')

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }



RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.use_transactional_fixtures = false
  config.include FactoryGirl::Syntax::Methods
  config.include RequestHelpers, type: :request

  config.before(:suite) do
    DatabaseCleaner[ATTACHINARY_ORM].strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner[ATTACHINARY_ORM].start
  end

  config.after(:each) do
    DatabaseCleaner[ATTACHINARY_ORM].clean
  end

  config.after(:suite) do
    print "\n\n Cleaning up uploaded files"

    begin
      Cloudinary::Api.delete_resources_by_tag('test_env')
      print " (done)"
    rescue Cloudinary::Api::RateLimited => e
      print " (#{e.message})"
    end

    print "\n\n"
  end
end
