require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    # @see https://github.com/DatabaseCleaner/database_cleaner/issues/445
    DatabaseCleaner.clean_with(:truncation, except: %w(ar_internal_metadata))
  end

  config.before(:each) do |example|
    # Switch to truncation if example uses a javascript driver or required by example metadata
    strategy = example.metadata[:strategy] if example.metadata[:strategy]
    strategy ||= example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.strategy = strategy
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    print "\n\n Cleaning up uploaded files"

    begin
      Cloudinary::Api.delete_resources_by_tag('test_env')
      print ' (done)'
    rescue Cloudinary::Api::RateLimited => e
      print " (#{e.message})"
    end

    print "\n\n"
  end

end
