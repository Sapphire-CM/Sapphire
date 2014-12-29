FactoryGirl.define do
  factory :submission_asset do
    submission
    submitted_at '2015-01-01 09:10:11'
    content_type 'foobar'
    file do
      src_file = File.join Rails.root, 'spec', 'support', 'data', 'simple_submission.txt'
      dst_file = File.join(Rails.root, 'tmp', 'simple_submission.txt')
      FileUtils.cp src_file, dst_file
      File.open(dst_file)
    end
  end
end
