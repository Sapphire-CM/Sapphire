require 'rails_helper'

RSpec.describe 'Viewing results' do
  let(:course) { FactoryGirl.create(:course) }
  let(:term) { FactoryGirl.create(:term, course: course, title: 'Fancy Term') }
  let(:term_registration) { FactoryGirl.create(:term_registration, :student, term: term) }
  let!(:account) { term_registration.account }
  let!(:exercise) { FactoryGirl.create(:exercise, title: 'Fancy Exercise', term: term) }
  let(:submission) { FactoryGirl.create(:submission, exercise: exercise, submitter: account) }
  let!(:exercise_registration) { FactoryGirl.create(:exercise_registration, submission: submission, term_registration: term_registration, exercise: exercise) }

  before :each do
    exercise.result_publications.update_all(published: true)
    sign_in account
  end

  describe 'navigating to the results page' do
    before :each do
      visit root_path
    end

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

  describe 'viewing results' do
    let!(:rating_groups) { FactoryGirl.create_list(:rating_group, 2, :with_ratings, exercise: exercise, points: 7, enable_range_points: false) }

    let(:rating_group) { rating_groups.first }
    let(:rating) { rating_group.ratings(true).last }

    scenario 'visiting results page of submission without any wrongdoings' do
      visit term_result_path(term, exercise)

      expect(page).to have_content("Well Done!")
      expect(page).to have_content("14 out of 14")

      expect(page).not_to have_content(rating.title)
      expect(page).not_to have_content(rating_group.title)
    end

    scenario 'viewing failed evaluations' do
      rating.evaluations.each { |evaluation| evaluation.update(value: 1) }
      rating.update(value: -5)

      visit term_result_path(term, exercise)

      expect(page).not_to have_content("Well Done!")
      expect(page).to have_content("9 out of 14")
      expect(page).to have_content(rating_group.title)
      expect(page).to have_content("2/7")

      within "table" do
        expect(page).to have_content(rating.title)
        expect(page).to have_content("-5")
      end
    end
  end

  describe 'errors' do
    scenario 'navigating to unpublished results page redirects to root path' do
      exercise.result_publications.update_all(published: false)

      visit term_result_path(term, exercise)

      expect(page).to have_current_path(root_path)
    end

    scenario 'navigating to results without submission redirects to new submission page' do
      submission.destroy

      visit term_result_path(term, exercise)

      expect(page).to have_current_path(new_exercise_student_submission_path(exercise))
    end
  end
end
