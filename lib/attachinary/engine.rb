require 'attachinary/active_record_extension'
require 'attachinary/view_helpers'

module Attachinary
  class Engine < ::Rails::Engine
    isolate_namespace Attachinary

    initializer "attachinary.extend_active_record" do |app|
      ActiveSupport.on_load :active_record do
        extend ActiveRecordExtension
      end
      ActiveSupport.on_load :action_view do
        include ViewHelpers
      end
    end

  end
end
