FactoryGirl.define do
  factory :submission do
    student_group_registration
    submitted_at {Time.now}
    exercise
  end
end
