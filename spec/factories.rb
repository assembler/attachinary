FactoryGirl.define do

  factory :file, class: Attachinary::File do
    sequence(:public_id) { |n| "id_#{n}"}
    sequence(:version) { |n| "version_#{n}"}
    width 800
    height 600
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
