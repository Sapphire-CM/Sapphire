require 'rails_helper'

RSpec.describe SubmissionAssetsController do
  render_views
  include_context 'active_admin_session_context'

  let(:valid_attributes) do
    {
      submission_asset: {
        file: 'foobar',
        submission_id: '42',
      }
    }
  end

  let(:invalid_attributes) do
    {
      submission_asset: {
        file: 'foobar',
        submission_id: '42',
      }
    }
  end

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

  describe 'GET new' do
    it 'assigns a new submission_asset as @submission_asset' do
      xhr :get, :new, submission_id: submission.id

      expect(response).to have_http_status(:success)
      expect(assigns(:submission_asset)).to be_a_new(SubmissionAsset)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new SubmissionAsset' do
        valid_attributes[:submission_asset][:file] = Rack::Test::UploadedFile.new(submission_asset.file.to_s, 'text/html')
        valid_attributes[:submission_asset][:submission_id] = submission.id

        expect {
          xhr :post, :create, valid_attributes
        }.to change(SubmissionAsset, :count).by(1)

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:create)
        expect(assigns(:submission_asset)).to be_a(SubmissionAsset)
        expect(assigns(:submission_asset)).to be_persisted
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved submission_asset as @submission_asset' do
        invalid_attributes[:submission_asset][:file] = Rack::Test::UploadedFile.new(submission_asset.file.to_s, 'text/html')

        xhr :post, :create, invalid_attributes

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(assigns(:submission_asset)).to be_a_new(SubmissionAsset)
      end
    end
  end
end
