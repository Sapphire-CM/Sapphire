require 'rails_helper'

RSpec.describe SubmissionFoldersController, type: :controller do
  include_context "active student session with submission"

  describe 'GET #show' do
    it 'assigns @submission and @submission_folder and responds to json' do
      get :show, params: { submission_id: submission.id, submission_folder: { path: "", name: "test" } }, format: :json

      expect(assigns[:submission]).to eq(submission)
      expect(assigns[:submission_folder]).to be_a(SubmissionFolder)
      expect(assigns[:submission_folder].submission).to eq(submission)
    end

    it 'does not respond to HTML requests' do
      get :show, params: { submission_id: submission.id, submission_folder: { path: "", name: "test" } }, format: :html
      expect(response).to render_template("record_not_found")
    end
  end

  describe 'GET #new' do
    it 'assigns @submission, @submission_folder, @exercise, and @term' do
      get :new, params: { submission_id: submission.id }

      expect(assigns[:submission]).to eq(submission)
      expect(assigns[:exercise]).to eq(exercise)
      expect(assigns[:term]).to eq(term)
      expect(assigns[:submission_folder]).to be_a(SubmissionFolder)
      expect(assigns[:submission_folder].submission).to eq(submission)
      expect(response).to render_template("new")
    end
  end

  describe 'POST #create' do
    it 'redirects to the specified path' do
      post :create, params: { submission_id: submission.id, submission_folder: { path: "test/folder", name: "new_folder" } }

      expect(response).to redirect_to(tree_submission_path(submission, path: "test/folder/new_folder"))
    end
  end
end
