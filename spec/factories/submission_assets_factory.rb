FactoryBot.define do
  factory :submission_asset do
    submission
    submitted_at { '2015-01-01 09:10:11' }
    content_type { 'foobar' }
    file { prepare_static_test_file 'simple_submission.txt', open: true }
    sequence(:path) {|i| "simple/submission/path#{i}" }
    submitter { association(:account) }

    trait :zip do
      file { prepare_static_test_file 'submission.zip', open: true }
      content_type { SubmissionAsset::Mime::ZIP }
    end

    trait :plain_text do
      file { prepare_static_test_file 'simple_submission.txt', open: true }
      content_type { SubmissionAsset::Mime::PLAIN_TEXT }
    end
  end
end
