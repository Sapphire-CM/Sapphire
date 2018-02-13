require 'rails_helper'
require 'features/submission_management/behaviours/submission_tree_basic_operation_behaviour'

RSpec.describe 'Managing a submission tree as a staff member' do
  let(:account) { FactoryGirl.create(:account, :tutor) }
  let(:term) { term_registration.term }
  let(:term_registration) { account.term_registrations.tutors.last }
  let(:student_term_registration) { FactoryGirl.create(:term_registration, :student, term: term, tutorial_group: term_registration.tutorial_group) }

  let(:submission) { FactoryGirl.create(:submission, exercise: exercise) }
  let(:exercise) { FactoryGirl.create(:exercise, term: term) }
  let!(:exercise_registration) { FactoryGirl.create(:exercise_registration, term_registration: student_term_registration, exercise: exercise, submission: submission)}

  before :each do
    sign_in account
  end

  describe 'navigation' do
    scenario 'through the evaluations page' do
      visit submission_evaluation_path(submission.submission_evaluation)

      within ".evaluation-top-bar" do
        click_link "Files"
      end

      expect(page).to have_current_path(tree_submission_path(submission))
    end

    scenario 'through the submission edit page' do
      visit edit_submission_path(submission)

      click_link "Files"

      expect(page).to have_current_path(tree_submission_path(submission))
    end
  end

  it_behaves_like "basic submission tree operations"

  context 'exercise with viewer' do
    let(:exercise) { FactoryGirl.create(:exercise, :with_viewer, term: term) }

    scenario 'shows the "open viewer" link' do
      visit tree_submission_path(submission)

      expect(page).to have_link("Open Viewer", href: submission_viewer_path(submission))
    end
  end

  context 'exercise without viewer' do
    let(:exercise) { FactoryGirl.create(:exercise, :without_viewer, term: term) }

    scenario 'hides the "open viewer" link' do
      visit tree_submission_path(submission)

      expect(page).to have_no_link("Open Viewer")
    end
  end
end
