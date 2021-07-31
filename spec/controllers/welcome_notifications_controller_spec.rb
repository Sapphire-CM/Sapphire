require 'rails_helper'

RSpec.describe WelcomeNotificationsController, type: :controller do
  include_context 'active_admin_session_context'

  describe 'POST #create' do
    let(:term) { FactoryBot.create(:term) }
    let(:valid_params) { { term_id: term.id } }

    it 'schedules a send pending welcomes job' do
      expect(Notification::SendPendingWelcomesJob).to receive(:perform_later).with(term)

      post :create, params: valid_params
    end

    it 'redirects to the term show path' do
      post :create, params: valid_params

      expect(response).to redirect_to(term_path(term))
    end

    it 'renders 404 if term does not exist' do
      post :create, params: { term_id: 42 }

      expect(response).to have_http_status(:not_found)
    end
  end
end
