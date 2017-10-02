unless defined?(ATTACHINARY_ORM)
  ATTACHINARY_ORM = (ENV['ATTACHINARY_ORM'] || :active_record).to_sym
end

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
$LOAD_PATH.unshift File.expand_path('../../../../lib', __FILE__)
