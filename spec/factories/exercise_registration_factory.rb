FactoryBot.define do
  factory :exercise_registration do
    exercise
    term_registration
    submission { FactoryBot.create(:submission, exercise: exercise) }
    active { true }

    trait :active do
      active { true }
    end

    trait :inactive do
      active { false }
    end
  end
end
