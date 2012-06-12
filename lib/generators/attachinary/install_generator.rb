module Attachinary

  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../../templates", __FILE__)

    desc "Copies initializer script"

    def copy_initializer
      copy_file "attachinary.rb", "config/initializers/attachinary.rb"
    end

    def create_migration
      Rails::Generators.invoke('attachinary:migration', ['Attachinary'])
    end

  end

end
