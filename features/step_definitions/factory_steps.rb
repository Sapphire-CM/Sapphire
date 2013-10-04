Given /^a tutor with "(.*?)\/(.*?)"$/ do |email, password|
  FactoryGirl.create(:tutor_account, email: email, password: password)
end

Given(/^an account with email "(.*?)"$/) do |email|
  FactoryGirl.create(:account, email: email)
end

Given(/^there is a course called "(.*?)"$/) do |title|
  FactoryGirl.create(:course, title: title)
end

Given(/^there is a term called "(.*?)"$/) do |title|
  FactoryGirl.create(:term, title: title)
end

Given(/^there is a tutorial group called "(.*?)" in term "(.*?)"$/) do |title, term_title|
  FactoryGirl.create(:tutorial_group, title: title, term: Term.where(title: term_title).first)
end

Given(/^there is an exercise called "(.*?)" in term "(.*?)"$/) do |title, term_title|
  FactoryGirl.create(:exercise, title: title, term: Term.where(title: term_title).first)
end

Given(/^there are (\d+) submissions for "(.*?)"$/) do |sub_count, ex_title|
  exercise = Exercise.where(title: ex_title).first
  exercise = FactoryGirl.create(:exercise, title: ex_title) unless exercise

  FactoryGirl.create_list(:submission, sub_count.to_i, exercise: exercise)
end
Given(/^there are (\d+) students in "(.*?)" registered for "(.*?)"$/) do |stud_count, tut_group_title, ex_title|
  exercise = Exercise.where(title: ex_title).first
  exercise = FactoryGirl.create(:exercise, title: ex_title) unless exercise
  exercise.group_submission = false
  exercise.save!

  tutorial_group = TutorialGroup.where(title: tut_group_title).first
  tutorial_group = FactoryGirl.create(:tutorial_group, title: tut_group_title) unless tutorial_group

  student_groups = FactoryGirl.create_list(:solitary_student_group, stud_count.to_i, tutorial_group: tutorial_group)
  student_groups.each { |sg| sg.register_for exercise }
end

Given(/^there are these rating groups for "(.*?)"$/) do |ex_title, table|
  exercise = Exercise.where(title: ex_title).first
  exercise = FactoryGirl.create(:exercise, title: ex_title) unless exercise

  table.hashes.each do |hash|
    FactoryGirl.create :rating_group, hash.symbolize_keys.merge({exercise: exercise})
  end
end
