FactoryGirl.define do
  factory :submission do
    submitted_at { Time.now }
    exercise
    association :submitter, factory: :account

    trait :with_student_group_registration do
      transient do
        student_group_title 'G1-01'
      end

      after(:create) do |instance, evaluator|
        instance.student_group = create(:student_group, title: evaluator.student_group_title)
      end
    end
  end
end
