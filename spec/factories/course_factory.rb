FactoryGirl.define do
  sequence(:course_title) { |n| "Course #{n}" }
  factory :course do
    title { generate :course_title }
    description { generate :lorem_ipsum }
    locked false
  end
end
