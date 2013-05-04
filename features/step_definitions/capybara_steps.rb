When(/^I fill in "(.*?)" with "(.*?)"$/) do |what, with|
  fill_in what, with: with
end

When(/^I click on button "(.*?)"$/) do |link|
  click_button link
end


Then /^I should see "([^"]*)"$/ do |text|
  page.should have_content text
end

