FactoryGirl.define do
  factory :account, aliases: [:tutor_account] do
    forename "John"
    surname "Doe"
    email "tutor@student.tugraz.at"
    password  "secret"
    password_confirmation {password}
  end
  
end