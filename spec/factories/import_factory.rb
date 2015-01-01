FactoryGirl.define do
  factory :import do
    term
    file { File.open prepare_static_test_file 'import_data.csv' }
    status :pending

    import_mapping { Import::ImportMapping.new(
      0  => :group,
      3  => :surname,
      4  => :forename,
      6  => :matriculation_number,
      11 => :email,
      12 => :comment,
    )}

    import_options {{
      matching_groups: 'first',
      tutorial_groups_regexp: "\\AT(?<tutorial>[\\d]+)\\z",
      headers_on_first_line: '1',
      column_separator: ';',
      quote_char: '"',
      decimal_separator: ',',
      thousands_separator: '.',
    }}

    import_result {{
      total_rows: 0,
      processed_rows: 0,
      imported_students: 0,
      imported_tutorial_groups: 0,
      imported_term_registrations: 0,
      imported_student_groups: 0,
      imported_student_registrations: 0,
      problems: [],
    }}
  end
end
