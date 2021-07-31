require 'rails_helper'

RSpec.describe 'Managing submissions as a student' do
  let(:course) { FactoryBot.create(:course) }
  let(:term) { FactoryBot.create(:term, course: course, title: 'Fancy Term') }
  let(:term_registration) { FactoryBot.create(:term_registration, :student, term: term) }
  let!(:account) { term_registration.account }
  let!(:exercise) { FactoryBot.create(:exercise, title: 'Fancy Exercise', term: term)}

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

      click_sub_nav_link 'Submission'

      expect(page).to have_current_path(new_exercise_student_submission_path(exercise))
    end

    scenario 'though the navigation bar' do
      click_link 'Fancy Term'
      click_top_bar_link 'Fancy Exercise'
      click_sub_nav_link 'Submission'

      expect(page).to have_current_path(new_exercise_student_submission_path(exercise))
    end
  end

  describe 'creating submissions' do
    scenario 'for solitary exercises' do
      exercise.update(group_submission: false)

      visit new_exercise_student_submission_path(exercise)

      expect(page).to have_content("solitary")

      expect do
        click_link "Create a Submission for Fancy Exercise"
      end.to change(Submission, :count).by(1)

      expect(page).to have_current_path(tree_submission_path(Submission.last))
    end

    scenario 'for group exercises' do
      exercise.update!(group_submission: true)
      sg = FactoryBot.create(:student_group, tutorial_group: term_registration.tutorial_group)
      term_registration.update(student_group: sg)

      visit new_exercise_student_submission_path(exercise)

      expect(page).to have_content("group")
      expect(page).to have_content(account.fullname)

      click_link "Create a Submission for Fancy Exercise"

      expect(page).to have_current_path(tree_submission_path(Submission.last))
    end
  end
end
