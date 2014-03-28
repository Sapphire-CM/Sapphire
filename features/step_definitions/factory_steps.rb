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
  exercise = Exercise.where(title: ex_title).first_or_create

  table.hashes.each do |hash|
    FactoryGirl.create :rating_group, hash.symbolize_keys.merge({exercise: exercise})
  end
end

Given(/^there are these courses$/) do |table|
  table.hashes.each do |line|
    FactoryGirl.create(:course, title: line["title"])
  end
end

Given(/^there are these terms for "(.*?)"$/) do |course_title, table|
  course = Course.where(title: course_title).first_or_create

  table.hashes.each do |line|
    FactoryGirl.create(:term, course: course, title: line['title'])
  end
end


Given(/^I have got (\d+) points for "([^"]*?)" of course "([^"]*?)" in term "([^"]*?)"$/) do |points, exercise_title, course_title, term_title|
  course = FactoryGirl.create(:course, title: title) unless course = Course.where(title: course_title).first
  term = FactoryGirl.create(:term, course: course, title: title) unless term = course.terms.where(title: term_title).first
  exercise = FactoryGirl.create(:exercise, term: term, title: title) unless exercise = term.exercises.where(title: title).first

  student_group = FactoryGirl.create(:student_group_for_student, student: @acc)
  student_group_registration = FactoryGirl.create(:student_group_registration, student_group: student_group, exercise: exercise)
  submission = FactoryGirl.create(:submission, student_group_registration: student_group_registration)

  submission_evaluation = submission.submission_evaluation
  submission_evaluation.evaluation_result = points
  submission_evaluation.save!(validate: false)

end


Given(/^there are these exercises for term "([^"]*?)" for course "([^"]*?)"$/) do |term_title, course_title, table|
  course = FactoryGirl.create(:course) unless course = Course.where(title: course_title).first
  term = FactoryGirl.create(:term, course: course) unless term = course.terms.where(title: term_title).first

  table.hashes.each do |row|
    FactoryGirl.create(:exercise, term: term, title: row[:title])
  end
end

Given(/^I have submitted a submission "(.*?)" for "(.*?)"$/) do |filename, exercise_title|
  exercise = FactoryGirl.create(:exercise, title: exercise_title) unless exercise = Exercise.where(title: exercise_title).first
  term = exercise.term

  unless student_group = StudentGroup.joins(:students, :tutorial_group).where(tutorial_group: {term_id: term}, students: {id: @acc.id}).first
    puts "creating reg!"
    tutorial_group = FactoryGirl.create(:tutorial_group, term: term) unless tutorial_group = term.tutorial_groups.first
    student_group = FactoryGirl.create(:student_group, tutorial_group: tutorial_group)
    student_registration = FactoryGirl.create(:student_registration, student_group: student_group, student: @acc)
  end

  submission = FactoryGirl.create(:submission)
  FactoryGirl.create(:submission_asset, file: File.open(File.join(Rails.root, "spec/support/data", filename)), submission: submission)
  submission.assign_to(student_group)
end
