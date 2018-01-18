FactoryGirl.define do
  sequence(:grading_scale_grades) { |n| n.to_s }

  factory :grading_scale do
    grade { generate(:additional_account_email) }
    term
  end
end
