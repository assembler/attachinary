class Note < ActiveRecord::Base

  has_attachment :photo, accept: [:jpg, :png, :gif]
  has_attachments :images, accept: [:jpg, :png, :gif]

  validates :body, presence: true, length: { minimum: 5, maximum: 128 }
  validates :photo_id, presence: true

  attr_accessible :body

end
