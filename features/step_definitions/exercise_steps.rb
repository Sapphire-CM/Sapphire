Given(/^all results of exercise "(.*?)" are published$/) do |exercise_title|
  exercise = FactoryGirl.create(:exercise, title: exercise) unless exercise = Exercise.where(title: exercise_title).first

  exercise.result_publications.update_all(published: true)
end

Given(/^there are no uploads allowed for "(.*?)" for term "(.*?)" of course "(.*?)"$/) do |exercise_title, term_title, course_title|
  course = FactoryGirl.create(:course, title: course_title) unless course = Course.where(title: course_title).first
  term = FactoryGirl.create(:term, title: term_title) unless term = course.terms.where(title: term_title).first
  exercise = FactoryGirl.create(:exercise, title: exercise_title) unless exercise = term.exercises.where(title: exercise_title).first

  exercise.enable_student_uploads = false
  exercise.save
end

Then(/^student uploads should be allowed for "(.*?)"$/) do |exercise_title|
  Exercise.where(title: exercise_title).first.enable_student_uploads?.should be_true
end

Then(/^no student upload should be allowed for "(.*?)"$/) do |exercise_title|
  Exercise.where(title: exercise_title).first.enable_student_uploads?.should be_false
end
