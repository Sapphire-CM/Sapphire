FactoryGirl.define do
  factory :import do
    term
    file { File.open prepare_static_test_file 'import_data.csv' }
    status :pending
  end
end
