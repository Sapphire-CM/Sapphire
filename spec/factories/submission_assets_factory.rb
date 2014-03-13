FactoryGirl.define do
  factory :submission_asset do
    submission
    file { File.open(File.join(Rails.root, "spec", "support", "data", "simple_submission.txt"))}
    submitted_at "2013-09-03 11:32:55"
  end
end
