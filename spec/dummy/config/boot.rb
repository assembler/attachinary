unless defined?(ATTACHINARY_ORM)
  ATTACHINARY_ORM = (ENV["ATTACHINARY_ORM"] || :active_record).to_sym
end

require 'rubygems'
gemfile = File.expand_path('../../../../Gemfile', __FILE__)

if File.exist?(gemfile)
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
end

$:.unshift File.expand_path('../../../../lib', __FILE__)
