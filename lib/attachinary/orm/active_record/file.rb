module Attachinary
  class File < ::ActiveRecord::Base
    belongs_to :attachinariable, polymorphic: true
    include FileMixin
  end
end
