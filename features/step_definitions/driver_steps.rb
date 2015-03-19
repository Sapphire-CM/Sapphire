When(/^I press enter on "(.*?)"$/) do |element_selector|
  page.find(element_selector).native.send_keys(:enter)
end
