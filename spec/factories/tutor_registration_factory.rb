FactoryGirl.define do
  factory :tutor_registration do
    association :tutor, factory: :account
    tutorial_group
  end
end
