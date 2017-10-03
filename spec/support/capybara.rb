# Database cleaner should be loaded before capybara
require_relative 'database_cleaner'

require 'capybara/rspec'
require 'capybara-screenshot/rspec'

Capybara.asset_host = 'http://localhost:3000'

Capybara.always_include_port = true
# Allow running integration tests on chrome
Capybara.register_driver :chrome do |app|
  Capybara::Screenshot.registered_drivers[:chrome] = Capybara::Screenshot.registered_drivers[:selenium]
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end
# Chrome in headless mode
Capybara.register_driver(:headless_chrome) do |app|
  Capybara::Screenshot.registered_drivers[:headless_chrome] = Capybara::Screenshot.registered_drivers[:selenium]
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(chromeOptions: {args: %w[headless disable-gpu]})
  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end
# Select javascript driver with env variable, using chrome by default
Capybara.javascript_driver = ENV['JAVASCRIPT_DRIVER'].try(:to_sym) || :headless_chrome

# Keep up to the number of screenshots specified in the hash
Capybara::Screenshot.prune_strategy = {keep: 5}
