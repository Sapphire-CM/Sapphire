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

  it_behaves_like "basic submission tree operations"
end
