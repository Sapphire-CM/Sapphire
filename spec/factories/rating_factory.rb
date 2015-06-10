FactoryGirl.define do
  sequence(:rating_title) { |n| "Rating #{n}" }
  factory :rating do
    rating_group
    title { generate :rating_title }
    description { generate :lorem_ipsum }
    type 'Ratings::BinaryRating'
    value 10
    max_value 20
    min_value 5
    multiplication_factor 1.0
  end
end
