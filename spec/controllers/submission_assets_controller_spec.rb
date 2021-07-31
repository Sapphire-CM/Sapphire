require 'rails_helper'

RSpec.describe SubmissionAssetsController do
  render_views
  include_context 'active_admin_session_context'

  let(:submission) { FactoryGirl.create :submission }
  let!(:submission_asset) { FactoryGirl.create :submission_asset, submission: submission }

  describe 'GET show' do
    it 'assigns the requested submission_asset as @submission_asset' do
      expect(controller).to receive(:send_file).with(submission_asset.file.to_s, filename: submission_asset.filename, type: submission_asset.content_type, disposition: :inline) {
        # to prevent a 'missing template' error
        controller.head :ok
      }

      get :show, params: { id: submission_asset.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:submission_asset)).to eq(submission_asset)
    end
  end

  describe 'DELETE destroy' do
    it 'removes the submission asset' do
      delete :destroy, params: { id: submission_asset.id }

      expect(assigns(:submission_asset)).to eq(submission_asset)
      expect(response).to redirect_to(tree_submission_path(submission, path: submission_asset.path))
    end

    it 'informs the event service' do
      expect_any_instance_of(EventService).to receive(:submission_asset_destroyed!).and_call_original

      delete :destroy, params: { id: submission_asset.id }
    end
  end
end
