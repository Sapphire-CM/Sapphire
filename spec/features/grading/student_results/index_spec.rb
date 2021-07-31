require 'rails_helper'

RSpec.describe 'Viewing results' do
  let(:course) { FactoryBot.create(:course) }
  let(:term) { FactoryBot.create(:term, course: course, title: 'Fancy Term') }
  let(:term_registration) { FactoryBot.create(:term_registration, :student, term: term) }
  let!(:account) { term_registration.account }
  let!(:exercise) { FactoryBot.create(:exercise, title: 'Fancy Exercise', term: term) }
  let(:submission) { FactoryBot.create(:submission, exercise: exercise, submitter: account) }
  let!(:exercise_registration) { FactoryBot.create(:exercise_registration, submission: submission, term_registration: term_registration, exercise: exercise) }


  before :each do
    exercise.result_publications.update_all(published: true)
    sign_in account
  end

  describe 'navigating to the results page' do
    before :each do
      visit root_path
    end

    scenario 'through the side navigation' do
      visit term_path(term)
      click_side_nav_link "Results"

      expect(page).to have_current_path(term_results_path(term))
    end
  end

  describe 'side nav' do
    scenario 'highlights Results' do
      visit term_results_path(term)

      within ".side-nav li.active" do
        expect(page).to have_link("Results")
      end
    end
  end

  describe 'results table' do
    let!(:rating_groups) { FactoryBot.create_list(:rating_group, 2, :with_ratings, exercise: exercise, points: 12, max_points: 12, enable_range_points: false) }

    let(:rating_group) { rating_groups.last }
    let(:rating) { rating_group.ratings.reload.first }

    context 'results are published and an evaluation failed' do
      before :each do
        rating.update(value: -7)
        rating.evaluations.each { |evaluation| evaluation.update(value: 1) }
      end

      scenario 'viewing results' do
        visit term_results_path(term)

        within "table" do
          expect(page).to have_content(exercise.title)
          expect(page).not_to have_content("Not yet published")
          expect(page).to have_content(exercise.points)
          expect(page).to have_content("17")
          expect(page).to have_link("Details", href: term_result_path(term, exercise))
        end
        expect(page).not_to have_content("provisional grade")
      end

      scenario 'viewing grade' do
        visit term_results_path(term)

        expect(page).to have_content("Grade:")
        expect(page).not_to have_content("provisional grade")
      end
    end

    context 'exercise not published' do
      before :each do
        exercise.result_publications.update_all(published: false)
      end

      scenario 'viewing results' do
        visit term_results_path(term)

        within "table" do
          expect(page).to have_content(exercise.title)
          expect(page).to have_content("Not yet published")
          expect(page).to have_content(exercise.points)
          expect(page).not_to have_link("Details", href: term_result_path(term, exercise))
        end
      end

      scenario 'indicating grade will be available when results are published' do
        visit term_results_path(term)

        expect(page).to have_content("provisional grade")
        expect(page).not_to have_content("Grade:")
      end
    end
  end
end
