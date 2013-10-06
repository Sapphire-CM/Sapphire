FactoryGirl.define do
  factory :submission do
    student_group_registration
    exercise
    submitted_at {Time.now}
  end
end
