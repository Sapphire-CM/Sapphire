FactoryGirl.define do
  factory :term_registration do
    points 0
    account
    term
    role :student
    tutorial_group { FactoryGirl.create(:tutorial_group, term: term) }

    trait :student do
      role :student
    end

    trait :tutor do
      role :tutor
    end

    trait :lecturer do
      role :lecturer
      tutorial_group nil
    end

    trait :with_student_group do
      transient do
        student_group { create(:student_group) }
      end

      after(:create) do |term_registration, evaluator|
        term_registration.update(student_group: evaluator.student_group)
      end
    end
  end
end
