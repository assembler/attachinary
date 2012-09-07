module Attachinary
  class File < ::ActiveRecord::Base
    belongs_to :parent, polymorphic: true
    include FileMixin
  end
end
