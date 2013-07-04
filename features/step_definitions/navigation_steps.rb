
Given /^I am on (.+)$/ do |page_name|
  case page_name
  when "the home page" then
    visit root_path
  when "the account sign in page"
    visit new_account_session_path
  when "the password reset page"
    visit new_account_password_path
  else
    visit path_to(page_name)
  end
end
