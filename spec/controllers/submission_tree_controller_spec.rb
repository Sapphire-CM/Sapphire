require 'rails_helper'

RSpec.describe SubmissionTreeController, type: :controller do
  include_context "active student session with submission"

  describe 'GET #show' do
    it 'assigns @submission, @exercise, @term, @tree, and @submission_upload' do
      get :show, params: { id: submission.id }

      expect(response).to have_http_status(:ok)

      expect(assigns[:submission]).to eq(submission)
      expect(assigns[:exercise]).to eq(exercise)
      expect(assigns[:term]).to eq(term)
      expect(assigns[:tree]).to be_a(SubmissionStructure::Tree)
      expect(assigns[:directory]).to be_a(SubmissionStructure::Directory)
      expect(assigns[:submission_upload]).to be_a(SubmissionUpload)
    end

    it 'resolves the path if it is given' do
      get :show, params: { id: submission.id, path: "test-folder/path" }

      expect(assigns[:directory].path_without_root).to eq("test-folder/path")
      expect(assigns[:submission_upload].path).to eq("test-folder/path")
    end
  end

  describe 'GET #directory' do
    it 'assigns @tree' do
      get :directory, params: { id: submission.id, path: "test" }, format: :json

      expect(assigns[:tree]).to be_a(SubmissionStructure::Tree)
      expect(assigns[:directory]).to be_a(SubmissionStructure::Directory)
    end

    it 'does not respond to html' do
      get :directory, params: { id: submission.id }, format: :html

      expect(response).to render_template("record_not_found")
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE #destroy' do
    let!(:submission_assets) do
      [
        FactoryBot.create(:submission_asset, submission: submission, path: "", file: prepare_static_test_file("simple_submission.txt", rename_to: "top-level.txt")),
        FactoryBot.create(:submission_asset, submission: submission, path: "/test", file: prepare_static_test_file("simple_submission.txt", rename_to: "test.txt")),
        FactoryBot.create(:submission_asset, submission: submission, path: "/test/folder", file: prepare_static_test_file("simple_submission.txt", rename_to: "test2.txt"))
      ]
    end

    it 'removes the assets inside given folder' do
      expect do
        delete :destroy, params: { id: submission.id, path: "test" }
      end.to change(submission.submission_assets, :count).by(-2)

      expect(submission.submission_assets.reload.first.path).to be_blank
      expect(response).to redirect_to(tree_submission_path(submission.id, path: ""))
    end

    it 'informs the event service' do
      expect_any_instance_of(EventService).to receive(:submission_assets_destroyed!).and_call_original

      delete :destroy, params: { id: submission.id, path: "test" }
    end
  end
end
