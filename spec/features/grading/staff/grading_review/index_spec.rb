require 'rails_helper'

RSpec.feature 'Grading Reviews Page' do
  let!(:account) { FactoryBot.create(:account, :admin) }
  let!(:term) { FactoryBot.create(:term) }

  let(:described_path) { term_grading_reviews_path(term) }

  before :each do
    sign_in account
  end

  describe 'navigation' do
    scenario 'navigating to grading review page' do
      visit root_path

      click_link term.title
      click_top_bar_link 'Grading Review'

      expect(page).to have_current_path(described_path)
    end
  end

  describe 'List' do
    let(:student_account) { FactoryBot.create(:account, forename: 'Max', surname: 'Mustermann', email: 'max.mustermann@student.tugraz.at')}
    let(:student_group) { FactoryBot.create(:student_group_for_student, student: student_account)}
    let!(:term_registration) { FactoryBot.create(:term_registration, :student, term: term, account: student_account) }
    let!(:another_term_registration) { FactoryBot.create(:term_registration, :student, term: term) }
    let!(:exercise) { FactoryBot.create(:exercise, title: 'My Exercise', term: term) }
    let!(:rating_group) { FactoryBot.create(:rating_group, :with_ratings, exercise: exercise, points: 10) }
    let!(:submission) { FactoryBot.create(:submission, :evaluated, exercise: exercise) }
    let!(:exercise_registration) { FactoryBot.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission) }

    scenario 'hides students if no search is performed' do
      visit described_path

      expect(page).not_to have_content('Max Mustermann')
    end

    scenario 'searching for a student' do
      visit term_grading_reviews_path(term)

      fill_in :q, with: 'Max Muster'
      click_button 'Search'

      within_main do
        expect(page).to have_content('Max Mustermann')
        expect(page).to have_content('max.mustermann@student.tugraz.at')
        expect(page).to have_content(student_group.title)
        expect(page).to have_link("Show")
      end
    end
  end
end
