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

    trait :for_tutorial_group do
      transient do
        tutorial_group { create :tutorial_group }
      end

      after(:create) do |instance, evaluator|
        raise
        student_group = create(:student_group_with_students, tutorial_group: evaluator.tutorial_group)
        creation_service = SubmissionCreationService.new(student_group.students.first, instance)
        creation_service.save!
      end
    end
  end
end
