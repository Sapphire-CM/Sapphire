FactoryGirl.define do
  factory :import do
    term
    file { prepare_static_test_file 'import_data.csv', open: true }
    status :pending

    after :create do |import|
      import.import_mapping.update!(
        group:                0,
        surname:              3,
        forename:             4,
        matriculation_number: 6,
        email:                11,
        comment:              12,
      )
    end

    trait :with_errors do
      transient do
        error_count 3
      end

      after(:create) do |model, evaluator|
        model.import_result.update(success: false)

        evaluator.error_count.times do
          model.import_result.import_errors.create!(row: 42, entry: "'Unprocessable entry", message: "Could not parse line 42")
        end
      end
    end
  end
end
