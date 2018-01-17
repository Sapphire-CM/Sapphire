FactoryGirl.define do
  factory :import_error do
    row 42
    entry "'Unparsable entry;"
    message "Could not parse line 42"
    import_result
  end
end
