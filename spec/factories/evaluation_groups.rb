# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :evaluation_group do
    points 1
    percent 1.5
    rating_group nil
    submission_evaluation nil
  end
end
