FactoryGirl.define do
  factory :submission_asset do
    submission
    submitted_at '2015-01-01 09:10:11'
    content_type 'foobar'
    file { prepare_static_test_file 'simple_submission.txt', open: true }
    sequence(:path) {|i| "simple/submission/path#{i}" }
  end
end
