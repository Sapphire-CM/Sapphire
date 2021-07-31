require 'rails_helper'

RSpec.describe SubmissionViewersController do
  render_views
  include_context 'active_admin_session_context'

  describe 'GET show' do
    it 'assigns the requested viewer as @viewer' do
      exercise = FactoryBot.create(:exercise, :with_viewer)
      submission = FactoryBot.create(:submission, exercise: exercise)

      get :show, params: { id: submission.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:submission)).to eq(submission)
      expect(assigns(:viewer)).to be_present
    end
  end
end
