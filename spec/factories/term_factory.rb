FactoryBot.define do
  sequence(:term_title) { |n| "Term #{n}" }
  factory :term do
    title { generate :term_title }
    description { generate :lorem_ipsum }
    course

    trait :with_tutorial_groups do
      transient do
        tutorial_group_count { 3 }
      end

      after :create do |term, evaluator|
        create_list(:tutorial_group, evaluator.tutorial_group_count, term: term)
      end
    end
  end
end
