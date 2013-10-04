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

Then(/^I should see "([^"]*)"$/i) do |text|
  page.should have_content text
end

Then(/^I should see a link with "(.*?)"$/) do |link|
  find_link(link).visible?
end

Then(/^have a break$/) do
  require 'pry'; binding.pry
end

When(/^I create a new term called "(.*?)" on course "(.*?)"$/) do |term_title, course_title|
  course = Course.where(title: course_title).first
  course_div = find_by_id("course_id_#{course.id}")

  within(course_div) do
    find_link('Add Term').trigger 'click'
  end

  fill_in 'Title', with: 'My New Term'
  fill_in 'Description', with: 'Some New Description'

  click_on 'Save'
end

When(/^I update the term "(.*?)" on course "(.*?)" to "(.*?)"$/) do |old_term_title, course_title, new_term_title|
  course = Course.where(title: course_title).first
  term = course.terms.where(title: old_term_title).first

  course_div = find_by_id("course_id_#{course.id}")

  within(course_div) do
    find_by_id("term_id_#{term.id}").find_link('Edit').trigger 'click'
    find_link('Edit').trigger 'click'
  end

  fill_in 'Title', with: new_term_title

  click_on 'Save'
end

When(/^I delete the term "(.*?)" on course "(.*?)"$/) do |term_title, course_title|
  course = Course.where(title: course_title).first
  term = course.terms.where(title: term_title).first

  course_div = find_by_id("course_id_#{course.id}")

  within(course_div) do
    find_by_id("term_id_#{term.id}").find_link('Delete').trigger 'click'
  end
end

Then(/^I should see term entry "(.*?)" on course "(.*?)"$/) do |term_title, course_title|
    course = Course.where(title: course_title).first
    course_div = find("#course_id_#{course.id}")
    course_div.should have_content "#{term_title}"
end

Then(/^I should find the term "(.*?)" on course "(.*?)"$/) do |term_title, course_title|
  course = Course.where(title: course_title).first
  course.terms.where(title: term_title).count == 1
end

Then(/^I should not see term entry "(.*?)" on course "(.*?)"$/) do |term_title, course_title|
    course = Course.where(title: course_title).first
    course_div = find("#course_id_#{course.id}")
    course_div.should_not have_content "#{term_title}"
end

Then(/^I should not find the term "(.*?)" on course "(.*?)"$/) do |term_title, course_title|
  course = Course.where(title: course_title).first
  course.terms.where(title: term_title).empty?
end
