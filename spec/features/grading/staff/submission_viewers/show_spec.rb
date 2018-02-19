require 'rails_helper'

RSpec.feature 'Grading Review' do
  let!(:account) { FactoryGirl.create(:account) }
  let!(:term_registration) { FactoryGirl.create(:term_registration, :tutor, account: account) }
  let!(:student_term_registration) { FactoryGirl.create(:term_registration, :student, term: term) }
  let!(:exercise_registration) { FactoryGirl.create(:exercise_registration, exercise: exercise, submission: submission, term_registration: student_term_registration) }
  let(:term) { term_registration.term }
  let!(:exercise) { FactoryGirl.create(:exercise, :with_viewer, term: term) }
  let!(:submission) { FactoryGirl.create(:submission, exercise: exercise) }

  before :each do
    sign_in(account)
  end

  describe 'navigation' do
    scenario 'through the evaluation page' do
      visit submission_evaluation_path(submission.submission_evaluation)

      click_link 'Open Viewer'

      expect(page).to have_current_path(submission_viewer_path(submission))
    end

    scenario 'through the grading review page', js: true do
      visit term_grading_review_path(term, student_term_registration)

      within '.section-container' do
        click_link exercise.title

        click_link 'Open Viewer'
      end

      expect(page).to have_current_path(submission_viewer_path(submission))
    end

    scenario 'through the submission tree page' do
      visit tree_submission_path(submission)

      within ".submission-tree-toolbar" do
        click_link("Open Viewer")
      end

      expect(page).to have_current_path(submission_viewer_path(submission))
    end
  end
end
