$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'attachinary/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'attachinary'
  s.version     = Attachinary::VERSION
  s.authors     = ['Milovan Zogovic']
  s.email       = ['milovan.zogovic@gmail.com']
  s.homepage    = ''
  s.summary     = "attachinary-#{s.version}"
  s.description = 'Attachments handler for Rails that uses Cloudinary for storage.'

  s.files = Dir['{app,config,db,lib,vendor}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '>= 3.2'
  s.add_dependency 'cloudinary', '~> 1.1.0'
end
