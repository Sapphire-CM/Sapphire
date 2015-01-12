FactoryGirl.define do
  factory :export do
    type ''
    status 1
    term
    file nil

    factory :submission_export, class: 'SubmissionExport' do
      type 'SubmissionExport'
      base_path '%{course}-%{term}'
      solitary_path 'solitary/%{exercise}/'
      group_path ''
    end

    factory :excel_spreadsheet_export, class: 'ExcelSpreadsheetExport' do
      type 'ExcelSpreadsheetExport'
      summary '1'
      exercises '1'
      student_overview '1'
    end
  end
end
