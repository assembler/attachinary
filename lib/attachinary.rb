require 'attachinary/engine'

require 'attachinary/active_record_extension'
ActiveRecord::Base.extend Attachinary::ActiveRecordExtension

module Attachinary
end
