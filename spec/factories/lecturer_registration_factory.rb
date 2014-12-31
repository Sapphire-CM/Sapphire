FactoryGirl.define do
  factory :lecturer_registration do
    association :lecturer, factory: :account
    term
  end
end
