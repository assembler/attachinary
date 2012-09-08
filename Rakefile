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

#require 'rake/spectask'

# Spec::Rake::SpecTask.new(:spec) do |t|
#   t.libs << 'lib'
#   t.libs << 'spec'
#   t.pattern = 'spec/**/*_spec.rb'
#   t.verbose = false
# end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)


desc 'Run Devise tests for all ORMs.'
task :spec_all_orms do
  Dir[File.join(File.dirname(__FILE__), 'spec', 'orm', '*.rb')].each do |file|
    orm = File.basename(file).split(".").first
    exit 1 unless system "rake spec ATTACHINARY_ORM=#{orm}"
  end
end

task :default => :spec_all_orms
