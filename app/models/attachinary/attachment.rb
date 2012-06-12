module Attachinary
  class Attachment < ::ActiveRecord::Base
    belongs_to :parent, polymorphic: true, touch: true
    belongs_to :file, class_name: 'Attachinary::File', foreign_key: 'file_id'

    validates :parent_id, :parent_type, :scope, presence: true

    attr_accessible :parent_id, :parent_type, :file_id
  end
end
