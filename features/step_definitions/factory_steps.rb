Given /^a tutor with "(.*?)\/(.*?)"$/ do |email, password|
  FactoryGirl.create(:tutor_account, email: email, password: password)
end

Given(/^an account with email "(.*?)"$/) do |email|
  FactoryGirl.create(:account, email: email)
end

Given(/^there is a course "(.*?)"$/) do |title|
  FactoryGirl.create(:course, title: title)
end

Given(/^there is a term "(.*?)" in a course "(.*?)"$/) do |term_title, course_title|
  course = Course.where(title: course_title).first
  course = FactoryGirl.create(:course, title: course_title) unless course

  FactoryGirl.create(:term, title: term_title, course: course)
end

Given(/^there is a tutorial group "(.*?)" in term "(.*?)"$/) do |title, term_title|
  term = Term.where(title: term_title).first
  term = FactoryGirl.create(:term, title: term_title) unless term

  FactoryGirl.create(:tutorial_group, title: title, term: term)
end

Given(/^there is an exercise "(.*?)" in term "(.*?)"$/) do |title, term_title|
  term = Term.where(title: term_title).first
  term = FactoryGirl.create(:term, title: term_title) unless term

  FactoryGirl.create(:exercise, title: title, term: term)
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
