FactoryGirl.define do

  factory :file, class: Attachinary::File do
    sequence(:public_id) { |n| "id#{n}"}
    sequence(:version) { |n| "#{n}"}
    width 800
    height 600
    format 'jpg'
    resource_type 'image'
  end

  if defined? Attachinary::Attachment
    factory :attachment, class: Attachinary::Attachment do
      association :parent, factory: :note
      file
      scope 'photo'
    end
  end

  factory :note do
    sequence(:body) { |n| "Note ##{n}"}
    association :photo, factory: :file
  end

end
