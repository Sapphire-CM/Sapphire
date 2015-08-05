FactoryGirl.define do
  factory :exercise_registration do
    exercise
    term_registration
    submission { FactoryGirl.create(:submission, exercise: exercise) }
  end
end
