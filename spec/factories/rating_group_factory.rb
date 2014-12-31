FactoryGirl.define do
  sequence(:rating_group_title) { |n| "Rating Group #{n}" }
  factory :rating_group do
    exercise
    title { generate :rating_group_title }
    points 10
    description { generate :lorem_ipsum }
    global false
    min_points 0
    max_points 10
    enable_range_points true

    trait :with_ratings do
      after :create do |rating_group|
        FactoryGirl.create_list :rating, 4, rating_group: rating_group
      end
    end
  end
end
