FactoryGirl.define do
  factory :submission do
    submitted_at {Time.now}
    exercise
    student_group_registration nil

    trait :with_student_group_registration do
      ignore do
        student_group_title "G1-01"
      end

      after(:create) do |instance, evaluator|
        if instance.student_group_registration.blank?
          instance.student_group_registration = create(:student_group_registration,
            exercise: instance.exercise,
            student_group: create(:student_group,
              term: instance.exercise.term,
              title: evaluator.student_group_title
            )
          )
        end
      end
    end
  end
end
