class Note < ActiveRecord::Base

  has_attachment :photo, accept: [:jpg, :png, :pdf]
  has_attachments :images, accept: [:jpg, :png]

  validates :body, presence: true, length: { minimum: 5, maximum: 128 }
  validates :photo_id, presence: true

  attr_accessible :body

end
