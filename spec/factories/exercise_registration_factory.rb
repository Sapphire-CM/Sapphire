# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :exercise_registration do
    exercise
    term_registration
    submission
  end
end
