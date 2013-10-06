Given(/^I am not logged in$/) do
  visit destroy_account_session_path
end

Given(/^I am logged in$/) do
  acc = FactoryGirl.create(:account)

  visit '/accounts/sign_in'
  fill_in "account_email", :with => acc.email
  fill_in "account_password", :with => acc.password
  click_button "Sign in"
end

Given(/^no account with email "(.*?)" exists$/) do |email|
  Account.where(:email => email).destroy_all
end


