#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Attachinary'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'



Bundler::GemHelper.install_tasks

# Configure rspec rake task
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

# Configure default task
task default: :spec

# Remove cloudinary files created during spec executions
task cleanup: :environment do
  begin
    print "Cleaning up created resources in cloud #{Cloudinary.config.cloud_name}..."
    Cloudinary::Api.delete_resources_by_tag('test_env')
    print ' (done)'
  rescue Cloudinary::Api::RateLimited => e
    print " (#{e.message})"
  end
end
