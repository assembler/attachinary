require 'attachinary/view_helpers'

module Attachinary
  class Engine < ::Rails::Engine
    isolate_namespace Attachinary

    initializer "attachinary.include_view_helpers" do |app|
      ActiveSupport.on_load :action_view do
        include ViewHelpers
      end
    end

    initializer "attachinary.enable_simple_form" do |app|
      require "attachinary/simple_form" if defined?(::SimpleForm::Inputs::Base)
    end

  end
end
