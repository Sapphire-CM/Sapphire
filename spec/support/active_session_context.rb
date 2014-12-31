require 'rails_helper'

RSpec.shared_context 'active_admin_session_context' do
  before :each do
    @current_account = FactoryGirl.create(:account, :admin)
    sign_in @current_account
  end
end

RSpec.shared_context 'active_lecturer_session_context' do
  before :each do
    @current_account = FactoryGirl.create(:account, :lecturer)
    sign_in @current_account
  end
end

RSpec.shared_context 'active_tutor_session_context' do
  before :each do
    @current_account = FactoryGirl.create(:account, :tutor)
    sign_in @current_account
  end
end

RSpec.shared_context 'active_student_session_context' do
  before :each do
    @current_account = FactoryGirl.create(:account, :student)
    sign_in @current_account
  end
end
