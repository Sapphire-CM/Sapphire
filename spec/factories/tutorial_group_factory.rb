FactoryBot.define do
  sequence(:tutorial_group_title) { |n| "Tut group #{n}" }

  factory :tutorial_group do
    title { generate :tutorial_group_title }
    description { generate :lorem_ipsum }
    term

    trait :with_tutor do
      transient do
        tutor_account { create(:account) }
      end

      after(:create) do |tutorial_group, evaluator|
        create(:term_registration, :tutor, tutorial_group: tutorial_group, term: tutorial_group.term, account: evaluator.tutor_account)
      end
    end

    trait :with_students do
      transient do
        students_count { 3 }
      end

      after(:create) do |tutorial_group, evaluator|
        evaluator.students_count.times do |i|
          a = create(:account)

          create(:term_registration, :student, tutorial_group: tutorial_group, term: tutorial_group.term, account: a)
        end
      end
    end
  end
end
