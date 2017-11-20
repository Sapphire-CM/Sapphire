FactoryGirl.define do
  sequence(:course_title) { |n| "Course #{n}" }
  factory :course do
    title { generate :course_title }
    description { generate :lorem_ipsum }
    locked false

    trait :with_terms do
      transient do
        term_count 3
      end

      after(:create) do |course, evaluator|
        create_list(:term, evaluator.term_count, course: course)
      end
    end
  end
end
