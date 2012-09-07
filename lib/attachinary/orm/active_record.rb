require_relative 'file_mixin'
require_relative 'active_record/attachment'
require_relative 'active_record/file'
require_relative 'active_record/extension'

ActiveRecord::Base.extend Attachinary::ActiveRecordExtension
