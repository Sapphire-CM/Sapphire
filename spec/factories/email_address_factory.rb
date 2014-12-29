FactoryGirl.define do
  sequence(:additional_account_email) { |n| "additional_email_#{n}@example.com" }

  factory :email_address do
    email { generate(:additional_account_email) }
    account
  end
end
