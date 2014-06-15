FactoryGirl.define do
  factory :submission do
    submitted_at {Time.now}
    exercise
    student_group_registration nil
    trait :without_student_group_registration do
      student_group_registration nil
    end

    trait :with_student_group_registration do
      after(:create) do |instance|
        if instance.student_group_registration.blank?
          instance.student_group_registration = create(:student_group_registration,
            exercise: instance.exercise,
            student_group: create(:student_group, term:
              instance.exercise.term
            )
          )
        end
      end
    end
  end
end
