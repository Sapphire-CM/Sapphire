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

When(/^I click on link "(.*?)"$/) do |link|
  first(:link, link).click
end

Then(/^I should not see a link with class "(.*?)"$/) do |css_class|
  page.has_css?("a.#{css_class}").should be_false
end

Then(/^I should not see a link with title "(.*?)"$/) do |link_title|
  page.has_css?("a[title='#{link_title}']").should be_false
end

Then(/^I should see a link with "(.*?)"$/) do |link|
  page.has_link?(link).should be_true
end

Then(/^I should not see a link with "(.*?)"$/) do |link|
  page.has_link?(link).should be_false
end

Then(/^I should see a button with "(.*?)"$/) do |button|
  page.has_button?(button).should be_true
end

Then(/^I should see "([^"]*)"$/i) do |text|
  page.should have_content text
end

Then(/^I should not see "([^"]*)"$/i) do |text|
  page.should_not have_content text
end

Then(/^I should see the subtitle "(.*?)"$/) do |subtitle|
  page.should have_selector('#site_subtitle', text: subtitle)
end

Then(/^have a break$/) do
  require 'pry'; binding.pry
end

When(/^I create a new term "(.*?)" on course "(.*?)"$/) do |term_title, course_title|
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

Then(/^I should see a table "([^"]*?)" with these elements$/) do |table_selector, table|
  within_table(table_selector) do
    table.hashes.each do |line|
      should have_css("td, th", text: line["text"])
    end
  end
end


When(/^I submit closest form to "(.*?)"$/) do |selector|
  page.execute_script("jQuery(\"#{selector}\").closest('form').submit();")
end


Then(/^I should see an input with "(.*?)"$/) do |value|
  page.should have_xpath("//input[@value='#{value}']")
end

Given(/^there is an exercise "(.*?)" for term "(.*?)" of course "(.*?)"$/) do |exercise_title, term_title, course_title|
  course = FactoryGirl.create(:course, title: course_title) unless course = Course.where(title: course_title).first
  term = FactoryGirl.create(:term, title: term_title, course: course) unless term = course.terms.where(title: term_title).first
  FactoryGirl.create(:exercise, term: term, title: exercise_title) unless term.exercises.where(title: exercise_title).first
end

When(/^I navigate to the submission form of exercise "(.*?)"$/) do |exercise_title|
  exercise = Exercise.where(title: exercise_title).first
  term = exercise.term

  if @acc.student_of_term? term
    visit exercise_student_submission_path(exercise)
  else
    visit exercise_submissions_path(exercise)
  end
end

Then(/^save and open page$/) do
  save_and_open_page
end

