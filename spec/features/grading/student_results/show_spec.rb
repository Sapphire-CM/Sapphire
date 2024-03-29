require 'rails_helper'

RSpec.describe 'Viewing results' do
  let(:course) { FactoryBot.create(:course) }
  let(:term) { FactoryBot.create(:term, course: course, title: 'Fancy Term') }
  let(:tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }
  let(:term_registration) { FactoryBot.create(:term_registration, :student, term: term, tutorial_group: tutorial_group) }
  let!(:account) { term_registration.account }
  let!(:exercise) { FactoryBot.create(:exercise, title: 'Fancy Exercise', term: term) }
  let(:submission) { FactoryBot.create(:submission, exercise: exercise, submitter: account) }
  let!(:exercise_registration) { FactoryBot.create(:exercise_registration, submission: submission, term_registration: term_registration, exercise: exercise) }

  before :each do
    exercise.result_publications.update_all(published: true)

    sign_in account
  end

  describe 'navigating to the results page' do
    scenario 'through the navigation bar' do
      visit exercise_path(exercise)

      click_sub_nav_link "Results"

      expect(page).to have_current_path(term_result_path(term, exercise))
    end

    scenario 'through the results page' do
      visit term_results_path(term)

      within "table" do
        click_link "Details"
      end

      expect(page).to have_current_path(term_result_path(term, exercise))
    end
  end

  describe 'side nav' do
    scenario 'highlights Exercises' do
      visit term_result_path(term, exercise)

      within ".side-nav li.active" do
        expect(page).to have_link("Exercises")
      end
    end
  end

  describe 'reviewing results' do
    let!(:rating_groups) { FactoryBot.create_list(:rating_group, 2, :with_ratings, exercise: exercise, points: 7, enable_range_points: false) }

    let(:rating_group) { rating_groups.first }
    let(:other_rating_group) { rating_groups.second }
    let(:rating) { rating_group.ratings.reload.last }

    scenario 'visiting results page of submission without any wrongdoings' do
      visit term_result_path(term, exercise)

      expect(page).to have_content("Well Done!")
      expect(page).to have_content("14 out of 14")

      expect(page).not_to have_content(rating.title)
      expect(page).not_to have_content(rating_group.title)
    end

    scenario 'viewing failed evaluations' do
      rating.evaluations.each { |evaluation| evaluation.update(value: 1) }

      rating.reload
      rating.update(value: -5)

      visit term_result_path(term, exercise)

      expect(page).not_to have_content("Well Done!")
      expect(page).to have_content("9 out of 14")

      within ".rating-group-#{rating_group.id}" do
        expect(page).to have_content(rating_group.title)
        expect(page).to have_content("2/7")


        within "table" do
          expect(page).to have_content(rating.title)
          expect(page).to have_content("-5")
        end
      end

      within ".rating-group-#{other_rating_group.id}" do
        expect(page).to have_content(other_rating_group.title)
        expect(page).to have_content("7/7")

        expect(page).not_to have_selector("table")
      end
    end

    scenario 'viewinig individual subtractions' do
      exercise_registration.reload
      exercise_registration.update(individual_subtractions: -2)

      visit term_result_path(term, exercise)

      expect(page).not_to have_content("Well Done!")
      expect(page).to have_content("12 out of 14")
      expect(page).to have_content("Individual Subtractions")
      expect(page).to have_content("-2")
    end
  end

  describe 'errors' do
    scenario 'navigating to unpublished results page redirects to root path' do
      exercise.result_publications.update_all(published: false)

      visit term_result_path(term, exercise)

      expect(page).to have_current_path(root_path)
    end

    scenario 'navigating to results without submission redirects renders 404' do
      submission.reload
      submission.destroy

      visit term_result_path(term, exercise)

      expect(page).to have_content("404")
    end
  end
end
