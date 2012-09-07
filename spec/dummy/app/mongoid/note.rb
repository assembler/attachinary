class Note
  include Mongoid::Document
  include Mongoid::Timestamps
  field :body, type: String

end
