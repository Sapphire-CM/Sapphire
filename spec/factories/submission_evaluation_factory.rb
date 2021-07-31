FactoryBot.define do
  factory :submission_evaluation do
    submission { FactoryBot.create(:submission, :without_submission_evaluation)}

    trait :evaluated do
      association :evaluator, factory: :account
    end
  end
end

