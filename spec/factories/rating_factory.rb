FactoryGirl.define do
  sequence(:rating_title) { |n| "Rating #{n}" }
  factory :rating do
    rating_group
    title { generate :rating_title }
    description { generate :lorem_ipsum }
    type 'Ratings::FixedRating'
    value 10
    max_value 20
    min_value 5
    multiplication_factor 1.0

    trait :boolean_points do
      type 'Ratings::FixedPointsDeductionRating'
    end

    trait :boolean_percent do
      type 'Ratings::FixedPercentageDeductionRating'
    end

    trait :value_points do
      type 'Ratings::VariablePointsDeductionRating'
    end

    trait :value_percent do
      type 'Ratings::VariablePercentageDeductionRating'
    end

    trait :plagiarism do
      type 'Ratings::PlagiarismRating'
    end

  end
end
