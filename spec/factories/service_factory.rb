FactoryGirl.define do
  factory :service do
    exercise
    type ''
    properties {}

    trait :active do
      active true
    end

    trait :inactive do
      active false
    end

    factory :website_fetcher_service
  end
end
