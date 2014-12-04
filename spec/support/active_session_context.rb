require 'rails_helper'

RSpec.shared_context 'active_admin_session_context' do
  before :each do
    sign_in FactoryGirl.create(:account, :admin)
  end
end

RSpec.shared_context 'active_user_session_context' do
  before :each do
    sign_in FactoryGirl.create(:account, :user)
  end
end
