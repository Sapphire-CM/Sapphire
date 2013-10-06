FactoryGirl.define do
  factory :student_registration do
    association :student, factory: :account
    comment ""
    student_group
  end
end
