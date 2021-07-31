FactoryBot.define do
  factory :result_publication do
    exercise
    tutorial_group
    published { false }

    trait :published do
      published { true }
    end

    trait :concealed do
      published { false }
    end
  end
end
