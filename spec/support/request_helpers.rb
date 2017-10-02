module RequestHelpers

  def handle_alert
    page.execute_script "window.original_alert_function = window.alert"
    page.execute_script "window.alert_message = null"
    page.execute_script "window.alert = function(msg) { window.alert_message = msg; }"
    yield
  ensure
    page.execute_script "window.alert = window.original_alert_function"
  end

  def alert_message
    page.evaluate_script "window.alert_message"
  end

end

# Include module in features
RSpec.configure do |config|
  config.include RequestHelpers, type: :feature
end