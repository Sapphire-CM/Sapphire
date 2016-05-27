require 'rails_helper'

RSpec.describe SubmissionTreeController, type: :controller do
  include_context "active_student_session_context"

  let(:submission) { FactoryGirl.create(:submission, exercise: exercise) }
  let(:exercise) { FactoryGirl.create(:exercise, term: term) }
  let(:term) { term_registration.term }
  let(:term_registration) { current_account.term_registrations.first }
  let!(:exercise_registration) { FactoryGirl.create(:exercise_registration, term_registration: term_registration, exercise: exercise, submission: submission)}

  describe 'GET #show' do
    it 'assigns @submission, @exercise, @term, @tree, and @submission_upload' do
      get :show, id: submission.id

      expect(response).to have_http_status(:ok)

      expect(assigns[:submission]).to eq(submission)
      expect(assigns[:exercise]).to eq(exercise)
      expect(assigns[:term]).to eq(term)
      expect(assigns[:tree]).to be_a(SubmissionStructure::TreeNode)
      expect(assigns[:submission_upload]).to be_a(SubmissionUpload)
    end

    it 'resolves the path if it is given' do
      get :show, id: submission.id, path: "test-folder/path"

      expect(assigns[:tree].path_without_root).to eq("test-folder/path")
      expect(assigns[:submission_upload].path).to eq("test-folder/path")
    end
  end

  describe 'GET #directory' do
    it 'assigns @tree' do
      get :directory, id: submission.id, path: "test", format: :json

      expect(assigns[:tree]).to be_a(SubmissionStructure::TreeNode)
    end

    it 'does not respond to html' do
      expect do
        get(:directory, id: submission.id, format: :html)
      end.to raise_error(ActionController::UnknownFormat)
    end
  end

  describe 'DELETE #destroy' do
    let!(:submission_assets) do
      [
        FactoryGirl.create(:submission_asset, submission: submission, path: "", file: prepare_static_test_file("simple_submission.txt", rename_to: "top-level.txt")),
        FactoryGirl.create(:submission_asset, submission: submission, path: "/test", file: prepare_static_test_file("simple_submission.txt", rename_to: "test.txt")),
        FactoryGirl.create(:submission_asset, submission: submission, path: "/test/folder", file: prepare_static_test_file("simple_submission.txt", rename_to: "test2.txt"))
      ]
    end

    it 'removes the assets inside given folder' do
      expect do
        delete :destroy, id: submission.id, path: "test"
      end.to change(submission.submission_assets, :count).by(-2)

      expect(submission.submission_assets(true).first.path).to be_blank
    end
  end
end
