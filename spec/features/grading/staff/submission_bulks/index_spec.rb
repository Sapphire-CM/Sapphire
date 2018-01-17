require 'rails_helper'

RSpec.describe 'Bulk Submission Management' do
  let(:term) { FactoryGirl.create(:term) }
  let(:exercise) { FactoryGirl.create(:exercise, term: term, enable_bulk_submission_management: true) }
  let(:account) { FactoryGirl.create(:account) }
  let!(:term_registration) { FactoryGirl.create(:term_registration, :tutor, term: term, account: account) }

  before :each do
    sign_in(account)
  end

  describe 'navigation' do
    scenario 'navigating to the bulk submission management page through the submissions list' do
      visit exercise_submissions_path(exercise)

      click_link "Bulk Operation"

      expect(page).to have_current_path(new_exercise_submission_bulk_path(exercise))
    end
  end

  describe 'behaviour' do
    pending
  end
end