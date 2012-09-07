module Attachinary
  class File
    include ::Mongoid::Document
    include ::Mongoid::Timestamps
    include FileMixin

    field :public_id, type: String
    field :version, type: String
    field :width, type: Integer
    field :height, type: Integer
    field :format, type: String
    field :resource_type, type: String
  end
end
