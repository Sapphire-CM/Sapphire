Given(/^I am on (.+) page$/) do |page_name|
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

When(/^I visit the evaluations page of "(.*?)"$/) do |ex_title|
  ex = Exercise.where(title: ex_title).first
  ex = FactoryGirl.create(:exercise, :title) if ex.nil?

  visit exercise_evaluation_path(ex)
end
