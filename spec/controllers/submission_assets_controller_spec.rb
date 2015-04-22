require 'rails_helper'

RSpec.describe SubmissionAssetsController do
  render_views
  include_context 'active_admin_session_context'

  let(:submission) { FactoryGirl.create :submission }
  let(:submission_asset) { FactoryGirl.create :submission_asset, submission: submission }

  describe 'GET show' do
    it 'assigns the requested submission_asset as @submission_asset' do
      expect(controller).to receive(:send_file).with(submission_asset.file.to_s, filename: nil, type: submission_asset.content_type, disposition: :inline) {
        # to prevent a 'missing template' error
        controller.render nothing: true
      }

      get :show, id: submission_asset.id

      expect(response).to have_http_status(:success)
      expect(assigns(:submission_asset)).to eq(submission_asset)
    end
  end
end
