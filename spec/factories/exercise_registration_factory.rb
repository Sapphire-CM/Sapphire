FactoryGirl.define do
  factory :exercise_registration do
    exercise
    term_registration
    submission { FactoryGirl.create(:submission, exercise: exercise) }
    outdated false

    trait :recent do
      outdated false
    end

    trait :outdated do
      outdated true
    end
  end
end
