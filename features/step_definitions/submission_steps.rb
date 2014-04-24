Then(/^there should be (\d+) submissions?$/) do |count|
  Submission.count.should eq count.to_i
end