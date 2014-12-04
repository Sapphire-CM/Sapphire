FactoryGirl.define do
  sequence(:student_group_title) {|n| "Group #{n}"}
  factory :student_group do
    tutorial_group
    active true
    solitary true
    title { generate :student_group_title }

    factory :student_group_with_students do
      transient do
        students_count 4
      end

      after(:create) do |student_group, attrib|
        FactoryGirl.create_list(:student_registration, attrib.students_count, student_group: student_group)
      end
    end

    factory :solitary_student_group do
      solitary true

      transient do
        students_count 1
      end

      after(:create) do |student_group, attrib|
        FactoryGirl.create_list(:student_registration, attrib.students_count, student_group: student_group)
      end
    end

    factory :student_group_for_student do
      transient do
        student { FactoryGirl.create(:account) }
      end

      after(:create) do |student_group, attributes|
        FactoryGirl.create(:student_registration, student_group: student_group, student: attributes.student) if attributes.student
      end
    end
  end
end
