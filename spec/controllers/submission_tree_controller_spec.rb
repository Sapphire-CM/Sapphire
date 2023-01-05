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

  describe 'GET #rename_folders' do

    let!(:submission_assets) do
      assets = []
      assets << top_level_asset
      assets << sub_folder
      assets << subsub_folder
      assets
    end

    let(:top_level_asset) { FactoryBot.create(:submission_asset, submission: submission, path:"", file: prepare_static_test_file("simple_submission.txt", rename_to: "tl-text-1.txt")) }
    let(:sub_folder) { FactoryBot.create(:submission_asset, submission: submission, path: "sub-folder", file: prepare_static_test_file("simple_submission.txt", rename_to: "text-2.txt")) }
    let(:subsub_folder) { FactoryBot.create(:submission_asset, submission: submission, path: "sub-folder/subsub-folder", file: prepare_static_test_file("simple_submission.txt", rename_to: "text-3.txt")) }

    context 'when attempting to rename the root folder' do
      it 'does not update the root folder path' do
        get :rename_folders, params: { id: submission.id, path: top_level_asset.path, new_directory_name: "dummy_new_directory_name" }
        expect(top_level_asset.reload.path).to_not be_nil
      end

      it 'redirects to the submission_asset tree view with an alert' do
        get :rename_folders, params: { id: submission.id, path: top_level_asset.path, new_directory_name: "dummy_new_directory_name" }
        expect(response).to redirect_to tree_submission_path(submission)
        expect(flash[:alert]).to eq("Renaming root folder not allowed.")
      end
    end

    context 'when attempting to rename an empty directory aka. a directory not yet physically created' do
      it 'does not update the root folder path' do
        get :rename_folders, params: { id: submission.id, path: sub_folder.path, new_directory_name: "dummy_new_directory_name" }
        expect(sub_folder.reload.path).to_not be_nil
      end
    end

    context 'when attempting to rename a physically created directory' do
      it 'renders the rename template' do
        get :rename_folders, params: { id: submission.id, path: sub_folder.path, new_directory_name: "dummy_new_directory_name" }

        expect(response).to render_template(:'submission_folders/rename')
      end
    end

  end

  describe "PATCH #update_folder_name" do
    let!(:submission_assets) do
      assets = []
      assets << top_level_asset
      assets << sub_folder
      assets << sub_folder_2
      assets << subsub_folder
      assets
    end

    let(:top_level_asset) { FactoryBot.create(:submission_asset, submission: submission, path:"", file: prepare_static_test_file("simple_submission.txt", rename_to: "tl-text-1.txt")) }
    let(:sub_folder) { FactoryBot.create(:submission_asset, submission: submission, path: "sub-folder", file: prepare_static_test_file("simple_submission.txt", rename_to: "text-2.txt")) }
    let(:sub_folder_2) { FactoryBot.create(:submission_asset, submission: submission, path: "sub-folder-2", file: prepare_static_test_file("simple_submission.txt", rename_to: "text-2.txt")) }
    let(:subsub_folder) { FactoryBot.create(:submission_asset, submission: submission, path: "sub-folder/subsub-folder", file: prepare_static_test_file("simple_submission.txt", rename_to: "text-3.txt")) }

    new_directory_name = "dummy_new_directory_name"

    context "with valid params" do
      it "renames the sub_folder and updates the submission assets with the new path" do
        # Make request to rename directory
        patch :update_folder_name, params: { id: submission.id, path: sub_folder.path, new_directory_name: new_directory_name }

        expect(sub_folder.reload.path).to eq(new_directory_name)
      end

      it "redirects with a success notice after renaming the directory was successful" do
        new_directory_name = "dummy_new_directory_name"

        patch :update_folder_name, params: { id: submission.id, path: sub_folder.path, new_directory_name: new_directory_name }

        expect(response).to redirect_to tree_submission_path(submission)
        expect(flash[:notice]).to eq("Successfully renamed directory '#{sub_folder.path}' to '#{sub_folder.path.sub(File.basename(sub_folder.path), new_directory_name)}'.")
      end

    end

    context "with invalid params" do
      it "redirects with an alert if attempting to rename the directory with a taken name" do

        new_directory_name = "sub-folder"

        patch :update_folder_name, params: { id: submission.id, path: sub_folder_2.path, new_directory_name: new_directory_name}

        # Expect a redirect and alert message
        expect(response).to have_http_status(:redirect)
        expect(flash[:alert]).to eq("The folder name 'sub-folder' is already in use. Renaming 'sub-folder-2' was not successful.")
      end

      it "redirects with an notice if renaming the directory with the name it already has" do
        new_directory_name = "sub-folder"

        patch :update_folder_name, params: { id: submission.id, path: sub_folder.path, new_directory_name: new_directory_name }

        expect(response).to have_http_status(:redirect)
        expect(flash[:notice]).to eq("Directory is already called 'sub-folder'.")
      end
    end
  end


end
