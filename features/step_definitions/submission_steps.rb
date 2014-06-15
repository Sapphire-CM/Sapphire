Then(/^there should be (\d+) submissions?$/) do |count|
  Submission.count.should eq count.to_i
end

Then(/^there should be (\d+) submissions of different student groups$/) do |expected_count|
  real_count = Submission.count
  real_count.should eq expected_count.to_i

  Submission.includes(:student_group_registration)
    .map {|submission| submission.student_group_registration.student_group_id}.uniq
    .length.should eq real_count
end


Given(/^I have submitted a submission "(.*?)" for "(.*?)"$/) do |filename, exercise_title|
  exercise = FactoryGirl.create(:exercise, title: exercise_title, group_submission: false) unless exercise = Exercise.where(title: exercise_title).first
  term = exercise.term

  unless student_group = StudentGroup.active.for_term(term).for_student(@acc).where(solitary: exercise.solitary_submission?).first
    tutorial_group = FactoryGirl.create(:tutorial_group, term: term) unless tutorial_group = term.tutorial_groups.first

    student_group = FactoryGirl.create(:student_group, tutorial_group: tutorial_group, solitary: exercise.solitary_submission?)
    student_registration = FactoryGirl.create(:student_registration, student_group: student_group, student: @acc)
  end

  submission = FactoryGirl.create(:submission, exercise: exercise)
  FactoryGirl.create(:submission_asset, file: File.open(File.join(Rails.root, "spec/support/data", filename)), submission: submission)
  submission.assign_to_account(@acc)
  submission.save
end
