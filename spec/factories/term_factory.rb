FactoryGirl.define do
  sequence(:term_title) { |n| "Term #{n}" }
  factory :term do
    title { generate :term_title }
    description { generate :lorem_ipsum }
    course
  end
end
