module Attachinary
  class File < ::ActiveRecord::Base
    include FileMixin
  end
end
