require 'rails_helper'

RSpec.describe SubmissionFolderRenamesController, type: :controller do
  render_views
  include_context 'active_admin_session_context'

  describe 'GET #new' do
    let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
    let(:exercise) { FactoryBot.create(:exercise, term: term) }
    let(:term) { term_registration.term }
    let(:term_registration) { current_account.term_registrations.first }
    let(:current_account) { FactoryBot.create(:account, :student) }
    let(:directory) { submission.tree.resolve( "current_path") }

    before do
      allow(controller).to receive(:authorize).and_return(true)
      allow(controller).to receive(:verify_authorized).and_return(true)
      get :new, params: { submission_id: submission.id, format: "current_path", submission_folder_rename: { path_new: "test" } }
    end

    it 'responds with a HTTP 200 status code (:ok)' do
      expect(response).to have_http_status(:ok)
    end

    it 'assigns a SubmissionFolderRename to @submission_folder_rename' do
      expect(assigns[:submission_folder_rename]).to be_a(SubmissionFolderRename)
    end

    it 'assigns the correct attributes to @submission_folder_rename' do
      expect(assigns(:submission_folder_rename).renamed_at).to eq(Time.now.strftime("%Y-%m-%d %H:%M"))
      expect(assigns(:submission_folder_rename).path_old).to eq('current_path')
      expect(assigns(:submission_folder_rename).renamed_by).to eq(controller.current_account)
    end

    it 'assigns submission and directory to @submission_folder_rename' do
      expect(assigns(:submission_folder_rename).submission).to eq(submission)
      expect(assigns(:submission_folder_rename).directory).to be_a(SubmissionStructure::Directory)
    end
  end

  describe 'POST #create' do
    let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
    let(:exercise) { FactoryBot.create(:exercise, term: term) }
    let(:term) { term_registration.term }
    let(:term_registration) { current_account.term_registrations.first }
    let(:current_account) { FactoryBot.create(:account, :student) }
    let(:directory) { submission.tree.resolve( "old_path") }

    let(:valid_params) do
      {
        format: 'old_path',
        submission_id: submission.id,
        submission_folder_rename: {
          path_new: 'new_path'
        }
      }
    end

    it 'creates a new submission folder rename and redirects on success' do
      allow(controller).to receive(:authorize).and_return(true)
      allow(controller).to receive(:verify_authorized).and_return(true)
      allow_any_instance_of(SubmissionFolderRename).to receive(:save!).and_return(true)
      post :create, params: valid_params
      expect(response).to redirect_to(tree_submission_path(submission, directory.parent.try(:path_without_root)))
      expect(flash[:notice]).to be_present
    end

    it 'redirects with an alert message on failure' do
      allow(controller).to receive(:authorize).and_return(true)
      allow(controller).to receive(:verify_authorized).and_return(true)
      allow_any_instance_of(SubmissionFolderRename).to receive(:save!).and_return(false)
      post :create, params: valid_params
      expect(response).to redirect_to(tree_submission_path(submission, directory.parent.try(:path_without_root)))
      expect(flash[:alert]).to be_present
    end
  end

end
