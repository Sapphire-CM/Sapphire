Given /^I am not logged in$/ do
  visit destroy_account_session_path
end

Given(/^no account with email "(.*?)" exists$/) do |email|
  Account.where(:email => email).destroy_all
end
