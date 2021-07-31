FactoryBot.define do
  sequence(:account_forename) { |n| "John #{n}" }
  sequence(:account_email) { |n| "account_#{n}@student.tugraz.at" }
  sequence(:account_matriculation_number) { |n| "#{'%07d' % n}" }

  factory :account, aliases: [:tutor_account] do
    forename { generate(:account_forename) }
    email { generate(:account_email) }
    matriculation_number { generate(:account_matriculation_number) }

    surname { 'Doe' }
    password { 'secret' }
    password_confirmation { password }
    admin { false }

    trait :admin do
      admin { true }
    end

    trait :student do
      after :create do |account|
        FactoryBot.create(:term_registration, :student, account: account)
      end
    end

    trait :lecturer do
      after :create do |account|
        FactoryBot.create(:term_registration, :lecturer, account: account)
      end
    end

    trait :tutor do
      after :create do |account|
        FactoryBot.create(:term_registration, :tutor, account: account)
      end
    end
  end
end
