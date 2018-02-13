require 'rails_helper'
require 'features/submission_management/behaviours/submission_tree_basic_operation_behaviour'

RSpec.describe 'Managing a submission tree as a student' do
  let(:account) { FactoryGirl.create(:account, :student) }
  let(:term) { term_registration.term }
  let(:term_registration) { account.term_registrations.students.first }
  let(:submission) { FactoryGirl.create(:submission, exercise: exercise) }
  let(:exercise) { FactoryGirl.create(:exercise, term: term) }
  let!(:exercise_registration) { FactoryGirl.create(:exercise_registration, term_registration: term_registration, exercise: exercise, submission: submission)}

  before :each do
    sign_in account
  end

  it_behaves_like "basic submission tree operations"

  scenario "hides evaluations link" do
    visit tree_submission_path(submission)

    expect(page).to have_no_link("Evaluate")
  end


  scenario "hides evaluations link" do
    visit tree_submission_path(submission)

    within '.submission-tree-toolbar' do
      expect(page).to have_no_link("Edit")
    end
  end

  context 'exercise with viewer' do
    let(:exercise) { FactoryGirl.create(:exercise, :with_viewer, term: term) }

    scenario 'hides open viewer link' do
      visit tree_submission_path(submission)

      expect(page).to have_no_link("Open Viewer")
    end
  end
end
