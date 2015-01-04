require 'rails_helper'

RSpec.describe StaffSubmissionsController do
  render_views
  include_context 'active_admin_session_context'

  let!(:term) { FactoryGirl.create :term }
  let!(:exercise) { FactoryGirl.create :exercise, term: term }
  let!(:tutorial_group) { FactoryGirl.create :tutorial_group, term: term }
  let!(:submission) { FactoryGirl.create :submission, exercise: exercise }
  let!(:submission_asset) { FactoryGirl.create :submission_asset, submission: submission }

  describe 'GET index' do
    context 'with tutorial_group' do
      it 'works' do
        get :index, exercise_id: exercise.id, tutorial_group_id: tutorial_group.id

        expect(response).to have_http_status(:success)
      end
    end

    context 'without tutorial_group' do
      it 'works' do
        get :index, exercise_id: exercise.id

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET show' do
    it 'assigns the requested submission as @submission' do
      get :show, exercise_id: exercise.id, id: submission.id

      expect(response).to have_http_status(:success)
      expect(assigns(:submission)).to eq(submission)
    end
  end

  describe 'GET new' do
    it 'assigns a new submission as @submission' do
      get :new, exercise_id: exercise.id

      expect(response).to have_http_status(:success)
      expect(assigns(:submission)).to be_a_new(Submission)
      expect(assigns(:submission).submission_assets.size).to eq(1)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      context 'creates a new submission' do
        (0..2).each do |assets_count|
          it "with #{assets_count} submission_assets" do
            valid_attributes = {
              exercise_id: exercise.id,
              submission: {
                submission_assets_attributes: {}
              }
            }

            (1..assets_count).each do |asset|
              valid_attributes[:submission][:submission_assets_attributes]["#{asset}"] = {
                file: Rack::Test::UploadedFile.new(FactoryGirl.create(:submission_asset).file.to_s, 'text/html')
              }
            end

            expect do
              expect do
                post :create, valid_attributes
              end.to change(SubmissionAsset, :count).by(assets_count)
            end.to change(Submission, :count).by(1)

            expect(response).to redirect_to(exercise_submission_path(exercise, assigns(:submission)))
          end
        end
      end
    end

    describe 'with invalid params' do
      # can not happen
    end
  end

  describe 'GET edit' do
    it 'assigns the requested submission as @submission' do
      get :edit, exercise_id: exercise.id, id: submission.id

      expect(response).to have_http_status(:success)
      expect(assigns(:submission)).to eq(submission)
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested submission' do
        valid_attributes = {
          exercise_id: exercise.id,
          id: submission.id,
          submission: {
            submission_assets_attributes: {
              '0' => {
                id: submission_asset.id,
                file: Rack::Test::UploadedFile.new(FactoryGirl.create(:submission_asset).file.to_s, 'text/html')
              }
            }
          }
        }

        expect do
          expect do
            post :update, valid_attributes
          end.to change(SubmissionAsset, :count).by(0)
        end.to change(Submission, :count).by(0)

        expect(response).to redirect_to(exercise_submission_path(exercise, assigns(:submission)))
      end
    end

    describe 'with invalid params' do
      # can not happen
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested submission' do
      submission.reload # trigger creation

      expect do
        delete :destroy, exercise_id: exercise.id, id: submission.id
      end.to change(Submission, :count).by(-1)

      expect(response).to redirect_to(exercise_submissions_path(exercise))
    end
  end
end
