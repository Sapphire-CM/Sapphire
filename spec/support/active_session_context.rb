require 'rails_helper'

RSpec.shared_context 'active_admin_session_context' do
  let(:current_account) { FactoryGirl.create(:account, :admin) }
  before :each do
    sign_in current_account
  end
end

RSpec.shared_context 'active_lecturer_session_context' do
  let(:current_account) { FactoryGirl.create(:account, :lecturer) }
  before :each do
    sign_in current_account
  end
end

RSpec.shared_context 'active_tutor_session_context' do
  let(:current_account) { FactoryGirl.create(:account, :tutor) }
  before :each do
    sign_in current_account
  end
end

RSpec.shared_context 'active_student_session_context' do
  let(:current_account) { FactoryGirl.create(:account, :student) }
  before :each do
    sign_in current_account
  end
end

RSpec.shared_context 'active student session with submission' do
  include_context "active_student_session_context"

  let(:submission) { FactoryGirl.create(:submission, exercise: exercise) }
  let(:exercise) { FactoryGirl.create(:exercise, term: term) }
  let(:term) { term_registration.term }
  let(:term_registration) { current_account.term_registrations.first }
  let!(:exercise_registration) { FactoryGirl.create(:exercise_registration, term_registration: term_registration, exercise: exercise, submission: submission) }
end
