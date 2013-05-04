When(/^I fill in "(.*?)" with "(.*?)"$/) do |what, with|
  if what =~ /^[#\.]/
    find(what).set with
  else
    fill_in what, with: with
  end
end

When(/^I click on button "(.*?)"$/) do |link|
  click_button link
end


Then /^I should see "([^"]*)"$/ do |text|
  page.should have_content text
end

Then(/^i should see a link with "(.*?)"$/) do |link|
  find_link(link).visible?
end