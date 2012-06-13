FactoryGirl.define do

  factory :file, class: Attachinary::File do
    sequence(:public_id) { |n| "id#{n}"}
    sequence(:version) { |n| "#{n}"}
    width 800
    height 600
    format 'jpg'
    resource_type 'image'
  end

  factory :attachment, class: Attachinary::Attachment do
    association :parent, factory: :file
    file
    scope 'photo'
  end

  factory :note do
    sequence(:body) { |n| "Note ##{n}"}
    association :photo, factory: :file
  end

end
