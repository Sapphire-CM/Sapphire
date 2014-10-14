FactoryGirl.define do
  factory :term_registration do
    points 0
    account
    term
    role "student"
    tutorial_group

    # explicit redefinition - in case we want to change the default role later on
    trait :student do
      role "student"
      tutorial_group
    end

    trait :tutor do
      role "tutor"
      tutorial_group
    end

    trait :lecturer do
      role "lecturer"
      tutorial_group nil
    end
  end
end
