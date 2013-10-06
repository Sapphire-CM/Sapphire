FactoryGirl.define do
  sequence(:account_forename) {|n| "John #{n}"}
  sequence(:account_email) {|n| "account_#{n}@student.tugraz.at"}
  sequence(:account_matriculation_number) {|n| "#{"%07d" % n}"}
  factory :account, aliases: [:tutor_account] do
    forename {generate :account_forename}
    surname "Doe"
    email {generate :account_email}
    matriculation_number {generate :account_matriculation_number}
    password  "secret"
    password_confirmation {password}
  end

end
