require_relative 'file_mixin'
require_relative 'base_extension'
require_relative 'mongoid/extension'
require_relative 'mongoid/file'

Mongoid::Document::ClassMethods.send :include, Attachinary::Extension
