require_relative 'file_mixin'
require_relative 'base_extension'
require_relative 'active_record/extension'
require_relative 'active_record/file'

ActiveRecord::Base.extend Attachinary::Extension
