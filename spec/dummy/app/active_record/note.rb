class Note < ActiveRecord::Base

  has_attachment :photo, accept: [:jpg, :png, :gif]
  has_attachments :images, accept: [:jpg, :png, :gif], maximum: 3

  validates :body, presence: true, length: { minimum: 4, maximum: 128 }
  validates :photo, presence: true

  attr_accessible :body

end
