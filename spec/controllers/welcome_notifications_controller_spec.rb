require 'rails_helper'

RSpec.describe WelcomeNotificationsController, type: :controller do
  include_context 'active_admin_session_context'

  describe 'POST #create' do
    let(:term) { FactoryGirl.create(:term) }
    let(:valid_params) { { term_id: term.id } }

    it 'schedules a notification job' do
      expect(NotificationJob).to receive(:welcome_notifications_for_term).with(term)

      post :create, valid_params
    end

    it 'redirects to the term show path' do
      post :create, valid_params

      expect(response).to redirect_to(term_path(term))
    end

    it 'renders 404 if term does not exist' do
      post :create, term_id: 42

      expect(response).to have_http_status(:not_found)
    end
  end
end
