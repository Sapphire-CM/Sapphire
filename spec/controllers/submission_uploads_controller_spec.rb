require 'rails_helper'

RSpec.describe SubmissionUploadsController, type: :controller do
  include_context "active student session with submission"

  describe 'GET #new' do
    it 'assigns @submission, @submission_upload, @exercise, and @term' do
      get :new, params: { submission_id: submission.id }

      expect(assigns[:submission]).to eq(submission)
      expect(assigns[:exercise]).to eq(exercise)
      expect(assigns[:term]).to eq(term)
      expect(assigns[:submission_upload]).to be_a(SubmissionUpload)
      expect(assigns[:submission_upload].submission).to eq(submission)
      expect(response).to render_template("new")
    end

    it 'sets the path on the submission upload if given in params' do
      get :new, params: { submission_id: submission.id, path: "test/path" }

      expect(assigns[:submission_upload].path).to eq("test/path")
    end
  end

  describe 'POST #create' do
    let(:valid_plain_file_attributes) do
      {
        submission_id: submission.id,
        submission_upload: {
          path: "test",
          file: prepare_rack_uploaded_test_file("simple_submission.txt", content_type: "text/plain")
        }
      }
    end

    let(:valid_zip_attributes) do
      {
        submission_id: submission.id,
        submission_upload: {
          path: "test",
          file: prepare_rack_uploaded_test_file("submission.zip", content_type: "application/zip")
        }
      }
    end

    let(:invalid_attributes) do
      {
        submission_id: submission.id,
        submission_upload: {
          path: "test",
          file: ""
        }
      }
    end

    context "HTML" do
      context 'with valid attributes' do
        it 'creates a submission asset' do
          expect_any_instance_of(EventService).to receive(:submission_asset_uploaded!)
          expect do
            post :create, params: valid_plain_file_attributes, format: :html
          end.to change(submission.submission_assets, :count).by(1)

          expect(response).to redirect_to(new_submission_upload_path(submission, path: "test"))
        end

        it 'creates a submission asset and enqueues the zip extraction' do
          expect_any_instance_of(EventService).to receive(:submission_asset_uploaded!)
          expect(ZipExtractionJob).to receive(:perform_later)
          expect do
            post :create, params: valid_zip_attributes, format: :html
          end.to change(submission.submission_assets, :count).by(1)

          expect(response).to redirect_to(new_submission_upload_path(submission, path: "test"))
        end
      end

      context 'with invalid attributes' do
        it 'does not create a submission asset' do
          expect do
            post :create, params: invalid_attributes, format: :html
          end.not_to change(submission.submission_assets, :count)

          expect(assigns[:submission]).to eq(submission)
          expect(assigns[:exercise]).to eq(exercise)
          expect(assigns[:term]).to eq(term)
          expect(assigns[:submission_upload]).to be_a(SubmissionUpload)

          expect(response).to render_template("new")
        end
      end
    end

    context "JSON" do
      context 'with valid attributes' do
        it 'creates a submission asset' do
          expect_any_instance_of(EventService).to receive(:submission_asset_uploaded!)
          expect do
            post :create, params: valid_plain_file_attributes, format: :json
          end.to change(submission.submission_assets, :count).by(1)

          expect(assigns[:submission]).to eq(submission)
          expect(assigns[:submission_upload]).to be_a(SubmissionUpload)
          expect(assigns[:submission_upload].submission).to eq(submission)

          expect(response).to have_http_status(:ok)
          expect(response).to render_template("create")
        end

        it 'creates a submission asset and enqueues the zip extraction' do
          expect_any_instance_of(EventService).to receive(:submission_asset_uploaded!)
          expect(ZipExtractionJob).to receive(:perform_later)
          expect do
            post :create, params: valid_zip_attributes, format: :html
          end.to change(submission.submission_assets, :count).by(1)

          expect(response).to redirect_to(new_submission_upload_path(submission, path: "test"))
        end
      end

      context 'with invalid attributes' do
        it 'does not create a submission' do
          expect do
            post :create, params: invalid_attributes, format: :json
          end.not_to change(submission.submission_assets, :count)

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
