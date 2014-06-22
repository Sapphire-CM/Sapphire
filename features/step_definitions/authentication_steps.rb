def ensure_logged_out!
  unless @acc.nil?
    visit destroy_account_session_path
    @acc = nil
  end
end

def sign_in(account)
  ensure_logged_out!

  visit '/accounts/sign_in'
  fill_in "account_email", :with => account.email
  fill_in "account_password", :with => account.password
  click_button "Sign in"
  @acc = account
end

Given(/^I am not logged in$/) do
  visit destroy_account_session_path
end

Given(/^I am logged in$/) do
  unless @acc.nil?
    visit destroy_account_session_path
    @acc = nil
  end

  @acc = FactoryGirl.create(:account)

  sign_in(@acc)
end

Given(/^I am logged in as an? (student|admin)$/) do |role|
  sign_in case role
  when "student"  then FactoryGirl.create(:account, :student)
  when "lecturer" then FactoryGirl.create(:account, :lecturer)
  when "admin"    then FactoryGirl.create(:account, :admin)
  end
end


Given(/^I am logged in as a ([^\s]*?) for course "(.*?)"$/) do |role, course_title|
  course = FactoryGirl.create(:course, title: course_title) unless course = Course.where(title: course_title).first

  account = FactoryGirl.create(:account)

  case role
  when "lecturer" then
    FactoryGirl.create(:lecturer_registration, course: course, lecturer: account)
  when "student" then
    term = FactoryGirl.create(:term, course: course)
    tut_group = FactoryGirl.create(:tutorial_group, term: term)
    student_group = FactoryGirl.create(:student_group, term: term)
    FactoryGirl.create(:student_registration, student_group: student_group, student: account)
  end

  sign_in(account)
end

Given(/^I am logged in as a student of term "(.*?)" of course "(.*?)"$/) do |term_title, course_title|
  account = FactoryGirl.create(:account)

  course = FactoryGirl.create(:course, title: course_title) unless course = Course.where(title: course_title).first
  term = FactoryGirl.create(:term, title: term_title, course: course) unless term = course.terms.where(title: term_title).first

  tut_group = FactoryGirl.create(:tutorial_group, term: term)
  student_group = FactoryGirl.create(:student_group, term: term)

  FactoryGirl.create(:student_registration, student_group: student_group, student: account)

  sign_in(account)
end


Given(/^I am logged in as a tutor of "(.*?)" of term "(.*?)" of course "(.*?)"$/) do |tutorial_group_title, term_title, course_title|
  account = FactoryGirl.create(:account)

  course = FactoryGirl.create(:course, title: course_title) unless course = Course.where(title: course_title).first
  term = FactoryGirl.create(:term, title: term_title, course: course) unless term = course.terms.where(title: term_title).first
  tutorial_group =  FactoryGirl.create(:tutorial_group, title: tutorial_group_title, term: term) unless tutorial_group = term.tutorial_groups.where(title: tutorial_group_title).first

  FactoryGirl.create(:tutor_registration, tutorial_group: tutorial_group, tutor: account)
  sign_in(account)
end


Given(/^no account with email "(.*?)" exists$/) do |email|
  Account.where(:email => email).destroy_all
end



When(/^I sign in as "(.*?)"$/) do |email|
  account = Account.where(email: email).first
  account.password = "secret"
  account.password_confirmation = account.password

  account.save
  sign_in(account)
end
