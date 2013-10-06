FactoryGirl.define do
  sequence(:student_group_title) {|n| "Group #{n}"}
  factory :student_group do
    tutorial_group

    factory :student_group_with_students do
      ignore do
        students_count 4
      end

      after(:create) do |student_group, attrib|
        FactoryGirl.create_list(:student_registration, attrib.students_count, student_group: student_group)
      end
    end

    factory :solitary_student_group do
      solitary true

      ignore do
        students_count 1
      end

      after(:create) do |student_group, attrib|
        FactoryGirl.create_list(:student_registration, attrib.students_count, student_group: student_group)
      end
    end
  end
end
