FactoryGirl.define do
  factory :evaluation_group do
    rating_group
    submission_evaluation nil

    points 1
    percent 1.5
  end
end
