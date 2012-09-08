FactoryGirl.define do

  factory :note do
    sequence(:body) { |n| "Note ##{n}"}
    after_build do |note|
      note.photo = FactoryGirl.build(:file)
    end
  end

  factory :file, class: Attachinary::File do
    sequence(:public_id) { |n| "id#{n}"}
    sequence(:version) { |n| "#{n}"}
    width 800
    height 600
    format 'jpg'
    resource_type 'image'
  end

end
