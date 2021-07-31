FactoryBot.define do
  factory :exercise_attempt do
    exercise
    sequence(:title) { |n| "Attempt #{n}"}
    date { Time.now }
  end
end
