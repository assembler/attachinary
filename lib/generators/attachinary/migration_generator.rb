require 'rails/generators/active_record'

module Attachinary

  class MigrationGenerator < ActiveRecord::Generators::Base
    source_root File.expand_path("../../templates", __FILE__)

    def copy_attachinary_migration
      migration_template "migration.rb", "db/migrate/attachinary_create_tables"
    end
  end

end
