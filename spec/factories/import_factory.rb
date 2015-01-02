FactoryGirl.define do
  factory :import do
    term
    file { File.open prepare_static_test_file 'import_data.csv' }
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
  end
end
