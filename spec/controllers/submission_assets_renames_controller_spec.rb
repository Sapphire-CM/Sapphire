require 'rails_helper'

RSpec.describe SubmissionAssetsRenamesController, type: :controller do
  render_views
  include_context 'active_admin_session_context'

  describe 'GET #new' do
    let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
    let(:exercise) { FactoryBot.create(:exercise, term: term) }
    let(:term) { term_registration.term }
    let(:term_registration) { current_account.term_registrations.first }
    let(:current_account) { FactoryBot.create(:account, :student) }
    let(:submission_asset) { FactoryBot.create(:submission_asset, submission: submission, path: "", file: prepare_static_test_file("simple_submission.txt", rename_to: "file1.txt")) }

    before do
      get :new, params: { id: submission_asset.id, submission_asset_rename: { new_filename: "test" } }
    end

    it 'responds with a HTTP 302 status code (found)' do
      expect(response).to have_http_status(:found)
    end

    it 'assigns a SubmissionAssetRename to @rename' do
      expect(assigns[:rename]).to be_a(SubmissionAssetRename)
    end

    it 'assigns the correct attributes to @rename' do
      expect(assigns(:rename).renamed_at).to eq(Time.now.strftime("%Y-%m-%d %H:%M"))
      expect(assigns(:rename).filename_old).to eq(submission_asset.filename)
      expect(assigns(:rename).submission_asset).to eq(submission_asset)
      expect(assigns(:rename).submission).to eq(submission)
      expect(assigns(:rename).term).to eq(term)
    end
  end

  describe "POST #create" do
    let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
    let(:exercise) { FactoryBot.create(:exercise, term: term) }
    let(:term) { term_registration.term }
    let(:term_registration) { current_account.term_registrations.first }
    let(:current_account) { FactoryBot.create(:account, :student) }
    let(:submission_asset) { FactoryBot.create(:submission_asset, submission: submission, path: "", file: prepare_static_test_file("simple_submission.txt", rename_to: "file1.txt")) }
    subject { FactoryBot.create(:submission_asset_rename, submission: submission, submission_asset: submission_asset, new_filename: "file2.txt") }

    let(:valid_params) { { submission_asset_rename: { new_filename: "new_filename.txt" } } }
    let(:invalid_params) { { submission_asset_rename: { new_filename: "" } } }

    context "with valid params" do
      it "submission_assets_renames the submission asset and redirects to the submission tree with a success notice" do
        allow(controller).to receive(:authorize).and_return(true)
        allow(controller).to receive(:verify_authorized).and_return(true)
        post :create, params: { id: submission_asset.id }.merge(valid_params)
        submission_asset.reload
        expect(submission_asset.filename).to eq "new_filename.txt"
        expect(response).to redirect_to(tree_submission_path(submission_asset.submission, path: submission_asset.path))
        expect(flash[:notice]).to eq "Successfully renamed submission file"
      end
    end

    context "with invalid params" do
      it "does not rename the submission asset and redirects to the submission tree with an error alert" do
        allow(controller).to receive(:authorize).and_return(true)
        allow(controller).to receive(:verify_authorized).and_return(true)
        post :create, params: { id: submission_asset.id }.merge(invalid_params)
        submission_asset.reload
        expect(submission_asset.filename).to_not eq ""
        expect(response).to redirect_to(tree_submission_path(submission_asset.submission, path: submission_asset.path))
        expect(flash[:alert]).to eq "Error renaming submission file: invalid filename"
      end
    end
  end

  describe "#set_context" do
    let(:submission_asset) { FactoryBot.create(:submission_asset) }
    let(:controller) { described_class.new }

    before do
      allow(controller).to receive(:params).and_return(id: submission_asset.id)
      controller.send(:set_context)
    end

    it "sets @submission_asset to the correct submission asset" do
      expect(controller.instance_variable_get(:@submission_asset)).to eq(submission_asset)
    end

    it "sets @submission to the correct submission" do
      expect(controller.instance_variable_get(:@submission)).to eq(submission_asset.submission)
    end

    it "sets @term to the correct term" do
      expect(controller.instance_variable_get(:@term)).to eq(submission_asset.submission.term)
    end
  end

  describe "#rename_params" do
    let(:params) { ActionController::Parameters.new(submission_asset_rename: { new_filename: "new_filename.txt" }) }

    before { allow(controller).to receive(:params).and_return(params) }

    it "permits the new_filename parameter" do
      expect(controller.send(:rename_params)).to eq({ "new_filename" => "new_filename.txt" })
    end
  end
end
