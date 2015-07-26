require 'rails_helper'

RSpec.describe 'Managing submissions as a student' do
  let(:course) { FactoryGirl.create(:course) }
  let(:term) { FactoryGirl.create(:term, course: course, title: 'Fancy Term') }
  let(:term_registration) { FactoryGirl.create(:term_registration, term: term) }
  let!(:account) { term_registration.account }
  let!(:exercise) { FactoryGirl.create(:exercise, title: 'Fancy Exercise', term: term)}

  before :each do
    sign_in account
  end

  describe 'navigating to the submission page' do
    before :each do
      visit root_path
    end

    scenario 'through the term page' do
      click_top_bar_link 'Fancy Term'
      click_side_nav_link 'Exercises'

      within 'table' do
        click_link 'Fancy Exercise'
      end

      expect(page.current_path).to eq(exercise_student_submission_path(exercise))
    end

    scenario 'though the navigation bar' do
      click_top_bar_link 'Fancy Term'
      click_top_bar_link 'Fancy Exercise'

      expect(page.current_path).to eq(exercise_student_submission_path(exercise))
    end
  end

  describe 'submitting' do
    before :each do
      visit exercise_student_submission_path(exercise)
    end

    scenario 'a single file' do
      attach_file 'Fancy Exercise file', 'spec/support/data/simple_submission.txt'
      click_button 'Upload Submission'

      within 'table' do
        expect(page).to have_content('simple_submission.txt')
        expect(page).to have_content(account.forename)
        expect(page).to have_content(account.surname)
      end
    end

    scenario 'multiple single files'
    scenario 'a .zip file'
    scenario 'a file, which is too large'
  end

  scenario 'replacing a file'
  scenario 'removing a file'
end
