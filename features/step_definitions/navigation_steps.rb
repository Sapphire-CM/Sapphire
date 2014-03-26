def visit_page(page_name)
  case page_name
  when "the home" then
    visit root_path
  when "the account sign in"
    visit new_account_session_path
  when "the password reset"
    visit new_account_password_path
  else
    visit path_to(page_name)
  end
end

Given(/^I am on (.+) page$/) do |page_name|
  visit_page(page_name)
end

When(/^I visit the evaluations page of "(.*?)"$/) do |ex_title|
  ex = Exercise.where(title: ex_title).first
  ex = FactoryGirl.create(:exercise, :title) if ex.nil?

  visit exercise_evaluation_path(ex)
end

When(/^I navigate to (.+) page$/i) do |page_name|
  visit_page(page_name)
end

When(/^I navigate to the term "(.*?)" of course "(.*?)"$/) do |term_title, course_title|
  course = Course.where(title: course_title).first
  term = course.terms.where(title: term_title).first

  visit term_path(term)
end

When(/^I navigate to the exercise "(.*?)"$/) do |exercise_title|
  exercise = Exercise.where(title: exercise_title).first
  visit exercise_path(exercise)
end

When(/^I navigate to the results publication page of exercise "(.*?)"$/) do |exercise_title|
  exercise = Exercise.where(title: exercise_title).first
  visit exercise_result_publications_path(exercise)
end

When(/^I attach "(.*?)" to "(.*?)"$/) do |filename, input|
  attach_file(input, File.join(Rails.root, "spec/support/data", filename))
end

