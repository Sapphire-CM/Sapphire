require 'rails_helper'

RSpec.describe SubmissionAssetsController do
  render_views
  include_context 'active_admin_session_context'

  let(:submission) { FactoryBot.create :submission }
  let!(:submission_asset) { FactoryBot.create :submission_asset, submission: submission }

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

  describe 'GET rename' do
    it 'assigns the requested submission_asset as @submission_asset' do
      get :rename, params: { id: submission_asset.id }

      expect(assigns(:submission_asset)).to eq(submission_asset)
    end

    it 'renders the rename template' do
      get :rename, params: { id: submission_asset.id }

      expect(response).to render_template(:rename)
    end
  end


  describe 'PATCH update' do
    let(:new_filename) { 'new_filename.txt' }

    context 'with valid params' do
      it 'updates the submission_asset' do
        patch :update, params: { id: submission_asset.id, submission_asset: { filename: new_filename } }

        expect(submission_asset.reload.filename).to eq(new_filename)
      end

      it 'informs the event service' do
        expect_any_instance_of(EventService).to receive(:submission_asset_updated!).and_call_original

        patch :update, params: { id: submission_asset.id, submission_asset: { filename: new_filename } }
      end

      it 'redirects to the submission_asset tree view' do
        patch :update, params: { id: submission_asset.id, submission_asset: { filename: new_filename } }

        expect(response).to redirect_to(tree_submission_path(submission, path: submission_asset.path))
      end
    end

    context 'with invalid params' do
      let(:invalid_filename) { nil }

      it 'does not update the submission_asset' do
        patch :update, params: { id: submission_asset.id, submission_asset: { filename: invalid_filename } }

        expect(submission_asset.reload.filename).to_not be_nil
      end

      it 'redirects to the submission_asset tree view with an alert' do
        patch :update, params: { id: submission_asset.id, submission_asset: { filename: invalid_filename } }

        expect(response).to redirect_to(tree_submission_path(submission, path: submission_asset.path))
        expect(flash[:alert])
      end
    end
  end

end
