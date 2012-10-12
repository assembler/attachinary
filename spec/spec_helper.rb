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
DatabaseCleaner.strategy = :truncation


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
  #config.include Attachinary::Engine.routes.url_helpers, type: :request

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    print "\n\n Cleaning up uploaded files"
    begin
      begin
        print "."
        ids = Cloudinary::Api.resources_by_tag('test_env', max_results: 100)["resources"].map{|r| r["public_id"] }
        Cloudinary::Api.delete_resources(ids) unless ids.empty?
      end until ids.empty?
      print " (done)"
    rescue Cloudinary::Api::RateLimited => e
      print " (#{e.message})"
    end
    print "\n\n"
  end
end
