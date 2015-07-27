class Note
  include Mongoid::Document
  include Mongoid::Timestamps
  field :body, type: String

  has_attachment :photo, accept: [:jpg, :png, :gif]
  has_attachments :images, accept: [:jpg, :png, :gif], maximum: 3

  validates :body, presence: true, length: { minimum: 5, maximum: 128 }
  validates :photo, presence: true
end
