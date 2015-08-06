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

    trait :boolean_points do
      type 'Ratings::BinaryNumberRating'
    end

    trait :boolean_percent do
      type 'Ratings::BinaryPercentRating'
    end

    trait :value_points do
      type 'Ratings::ValueNumberRating'
    end

    trait :value_percent do
      type 'Ratings::ValuePercentRating'
    end

    trait :plagiarism do
      type 'Ratings::PlagiarismRating'
    end

  end
end
