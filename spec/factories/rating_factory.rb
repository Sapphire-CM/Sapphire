FactoryGirl.define do
  sequence(:rating_title) { |n| "Rating #{n}" }


  factory :fixed_points_deduction_rating, class: Ratings::FixedPointsDeductionRating do
    title { generate :rating_title }
    rating_group
    description { generate :lorem_ipsum }
    multiplication_factor 1.0

    value -3
  end

  factory :fixed_percentage_deduction_rating, class: Ratings::FixedPercentageDeductionRating do
    title { generate :rating_title }
    rating_group
    description { generate :lorem_ipsum }
    multiplication_factor 1.0

    value -25
  end

  factory :fixed_bonus_points_rating, class: Ratings::FixedBonusPointsRating do
    title { generate :rating_title }
    rating_group
    description { generate :lorem_ipsum }
    multiplication_factor 1.0

    value 4
  end

  factory :variable_points_deduction_rating, class: Ratings::VariablePointsDeductionRating do
    title { generate :rating_title }
    rating_group
    description { generate :lorem_ipsum }
    multiplication_factor 1.0

    max_value 0
    min_value -10
  end

  factory :variable_bonus_points_rating, class: Ratings::VariableBonusPointsRating do
    title { generate :rating_title }
    rating_group
    description { generate :lorem_ipsum }
    multiplication_factor 1.0

    max_value 10
    min_value 0
  end

  factory :variable_percentage_deduction_rating, class: Ratings::VariablePercentageDeductionRating do
    title { generate :rating_title }
    rating_group
    description { generate :lorem_ipsum }
    multiplication_factor 1.0

    max_value 0
    min_value -25
  end

  factory :per_item_points_deduction_rating, class: Ratings::PerItemPointsDeductionRating do
    title { generate :rating_title }
    rating_group
    description { generate :lorem_ipsum }

    max_value 8
    min_value 0

    multiplication_factor -4
  end


  factory :per_item_points_rating, class: Ratings::PerItemPointsRating do
    title { generate :rating_title }
    rating_group
    description { generate :lorem_ipsum }

    max_value 8
    min_value 0

    multiplication_factor 2
  end

  factory :plagiarism_rating, class: Ratings::PlagiarismRating do
    title { generate :rating_title }
    rating_group
    description { generate :lorem_ipsum }
    multiplication_factor 1.0
  end
end
