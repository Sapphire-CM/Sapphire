require 'rails_helper'

RSpec.feature 'Grading Review Page' do

  let!(:account) { FactoryGirl.create(:account, :admin) }

  let!(:term) { FactoryGirl.create(:term) }
  let!(:term_registration) { FactoryGirl.create(:term_registration, :student, term: term, account: student_account) }

  let(:described_path) { term_grading_review_path(term, term_registration) }

  let(:student_account) { FactoryGirl.create(:account, forename: 'Max', surname: 'Mustermann') }

  before :each do
    sign_in account
  end

  describe 'navigation' do
    scenario 'through the grading review list' do
      visit term_grading_reviews_path(term)

      fill_in :q, with: 'Max Muster'
      click_button 'Search'

      expect(page).to have_content('Max Mustermann')
      first('.small.button', text: 'Show').click

      expect(page).to have_current_path(term_grading_review_path(term, term_registration))
    end

    scenario 'through the students detail page' do
      visit term_student_path(term, term_registration)

      within_main do
        click_link "Grading Review"
      end

      expect(page).to have_current_path(described_path)
    end
  end

  describe 'grading review' do
    let!(:term_registration) { FactoryGirl.create(:term_registration, :student, term: term, account: student_account) }
    let!(:another_term_registration) { FactoryGirl.create(:term_registration, :student, term: term) }
    let!(:exercise) { FactoryGirl.create(:exercise, title: 'My Exercise', term: term) }
    let!(:rating_group) { FactoryGirl.create(:rating_group, :with_ratings, exercise: exercise, points: 10) }
    let!(:submission) { FactoryGirl.create(:submission, :evaluated, exercise: exercise) }
    let!(:exercise_registration) { FactoryGirl.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission) }

    scenario 'viewing a student\'s results', js: true do
      exercise.result_publications.each(&:publish!)

      visit term_grading_review_path(term, term_registration)

      within_main do
        expect(page).to have_content('Overview')

        within 'table' do
          expect(page).to have_content(exercise.title)
          expect(page).to have_content("10 / 10")
        end

        click_link exercise.title

        expect(page).to have_content('Well Done!')
      end
    end
  end
end
