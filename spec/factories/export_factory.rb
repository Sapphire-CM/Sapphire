FactoryGirl.define do
  factory :export do
    type ''
    status 1
    term
    file nil

    factory :submission_export, class: 'Exports::SubmissionExport' do
      type 'Exports::SubmissionExport'
      base_path '%{course}-%{term}'
      solitary_path 'solitary/%{exercise}/'
      group_path ''
    end

    factory :grading_export, class: 'Exports::GradingExport' do
      type 'Exports::GradingExport'
      summary '1'
      exercises '1'
      student_overview '1'
    end
  end
end
