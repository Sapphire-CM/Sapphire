FactoryGirl.define do
  factory :submission do
    submitted_at {Time.now}
    exercise
    association :submitter, factory: :account

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

    trait :for_tutorial_group do
      ignore do
        tutorial_group { create :tutorial_group }
      end

      after(:create) do |instance, evaluator|
        student_group = create(:student_group_with_students, tutorial_group: evaluator.tutorial_group, solitary: instance.exercise.solitary_submission? )
        instance.assign_to(student_group)
        instance.save!
      end
    end
  end
end
