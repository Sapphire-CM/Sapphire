FactoryGirl.define do
  sequence(:student_group_title) { |n| "Group #{n}" }
  factory :student_group do
    tutorial_group
    title { generate :student_group_title }

    factory :student_group_with_students do
      transient do
        students_count 4
      end

      after(:create) do |student_group, attrib|
        create_list(:term_registration, attrib.students_count, :with_student_group, student_group: student_group)
      end
    end

    factory :student_group_for_student do
      transient do
        student { FactoryGirl.create(:account) }
      end

      after(:create) do |student_group, evaluator|
        create(:term_registration, :with_student_group, student_group: student_group, account: evaluator.student)
      end
    end
  end
end
