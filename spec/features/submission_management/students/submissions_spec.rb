require 'rails_helper'

RSpec.describe 'Managing submissions as a student' do
  let(:course) { FactoryGirl.create(:course) }
  let(:term) { FactoryGirl.create(:term, course: course, title: 'Fancy Term') }
  let(:term_registration) { FactoryGirl.create(:term_registration, :student, term: term) }
  let!(:account) { term_registration.account }
  let!(:exercise) { FactoryGirl.create(:exercise, title: 'Fancy Exercise', term: term)}

  before :each do
    sign_in account
  end

  describe 'navigating to the new submission page' do
    before :each do
      visit root_path
    end

    scenario 'through the term page' do
      click_link 'Fancy Term'
      click_side_nav_link 'Exercises'

      within 'table' do
        click_link 'Fancy Exercise'
      end

      expect(page).to have_current_path(new_exercise_student_submission_path(exercise))
    end

    scenario 'though the navigation bar' do
      click_link 'Fancy Term'
      click_top_bar_link 'Fancy Exercise'

      expect(page).to have_current_path(new_exercise_student_submission_path(exercise))
    end
  end

  describe 'creating submissions' do
    scenario 'for solitary exercises' do
      exercise.update(group_submission: false)

      visit new_exercise_student_submission_path(exercise)

      expect(page).to have_content("solitary")

      click_link "Create a Submission for Fancy Exercise"

      expect(page).to have_current_path(tree_submission_path(Submission.last))
    end

    scenario 'for group exercises' do
      exercise.update!(group_submission: true)
      sg = FactoryGirl.create(:student_group, tutorial_group: term_registration.tutorial_group)
      term_registration.update(student_group: sg)

      visit new_exercise_student_submission_path(exercise)

      expect(page).to have_content("group")
      expect(page).to have_content(account.fullname)

      click_link "Create a Submission for Fancy Exercise"

      expect(page).to have_current_path(tree_submission_path(Submission.last))
    end
  end
end
