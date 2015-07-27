# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"
ATTACHINARY_ORM ||= (ENV["ATTACHINARY_ORM"] || :active_record).to_sym

# $:.unshift File.dirname(__FILE__)
# require 'rspec/rails'
# require "dummy/config/environment.rb"
SPEC_ROOT = "#{::Rails.root}/.."
require "#{SPEC_ROOT}/orm/#{ATTACHINARY_ORM}"

require 'valid_attribute'
require 'capybara/rspec'

require 'factory_girl'
require "#{SPEC_ROOT}/factories"

require 'database_cleaner'

require "capybara/webkit"
Capybara.javascript_driver = :webkit

Capybara::Webkit.configure do |config|
  config.allow_url("api.cloudinary.com")
  config.allow_url("res.cloudinary.com")
end

# ENGINE_RAILS_ROOT = File.join(File.dirname(__FILE__), '../')

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
# Uncomment next line to load all support files, if you have more than one
# Uncomment next line to load all support files, if you have more than one
# Dir[File.join(ENGINE_RAILS_ROOT, "../../spec/support/**/*.rb")].each {|f| require f }
require "#{SPEC_ROOT}/support/request_helpers"

RSpec.configure do |config|
  config.color = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.use_transactional_fixtures = false
  config.include FactoryGirl::Syntax::Methods
  config.include RequestHelpers, type: :feature

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do |example|
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
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
