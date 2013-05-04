Given /^a tutor with "(.*?)\/(.*?)"$/ do |email, password|
  FactoryGirl.create(:tutor_account, email: email, password: password)
end

Given(/^an account with email "(.*?)"$/) do |email|
  FactoryGirl.create(:account, email: email)
end
