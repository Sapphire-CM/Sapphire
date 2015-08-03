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

    trait :with_exercise_registrations do
      transient do
        exercise_registrations_count 3
      end

      after(:create) do |instance, evaluator|
        create_list(:exercise_registration, evaluator.exercise_registrations_count, exercise: instance.exercise, submission: instance)
      end
    end

    trait :evaluated do
      after(:create) do |instance, evaluator|
        instance.submission_evaluation.update(evaluator: FactoryGirl.create(:account), evaluated_at: Time.now)
      end
    end

    trait :without_submission_evaluation do
      after(:create) do |instance, evaluator|
        instance.submission_evaluation.destroy
      end
    end
  end
end
