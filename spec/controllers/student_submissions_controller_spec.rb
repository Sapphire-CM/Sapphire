require 'rails_helper'

RSpec.describe StudentSubmissionsController do
  render_views
  include_context 'active_student_session_context'

  describe 'GET show' do
    context 'as student registered to a term' do
      it 'shows the submission' do
        term_registration = @current_account.term_registrations.first
        term = term_registration.term
        exercise = FactoryGirl.create :exercise, term: term

        get :show, exercise_id: exercise.id

        expect(response).to have_http_status(:success)
        expect(assigns(:term)).to eq(term)
        expect(assigns(:exercise)).to eq(exercise)
      end
    end

    context 'as unassociated user' do
      it 'redirect somewhere else' do
        term = FactoryGirl.create :term
        exercise = FactoryGirl.create :exercise, term: term

        get :show, exercise_id: exercise.id

        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'POST create' do
    let(:exercise) { FactoryGirl.create :exercise, term: @current_account.term_registrations.first.term }

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

            expect(response).to redirect_to(exercise_student_submission_path(exercise))
          end
        end
      end
    end

    describe 'with invalid params' do
      it 'redirects to submission page' do
        invalid_attributes = {
          exercise_id: exercise.id,
          submission: {
            submission_assets_attributes: {
              '0' => {
                file: ''
              }
            }
          }
        }

        expect do
          expect do
            post :create, invalid_attributes
          end.to change(SubmissionAsset, :count).by(0)
        end.to change(Submission, :count).by(1)

        expect(response).to redirect_to(exercise_student_submission_path(exercise))
      end
    end
  end

  describe 'PATCH update' do
    let(:term_registration) { @current_account.term_registrations.first }
    let(:exercise) { FactoryGirl.create :exercise, term: term_registration.term }
    let(:submission) { FactoryGirl.create :submission, exercise: exercise, submitter: @current_account }
    let(:submission_asset) { FactoryGirl.create :submission_asset, submission: submission }

    describe 'with valid params' do
      it 'creates a a new submission' do
        FactoryGirl.create :exercise_registration,
          exercise: exercise,
          term_registration: term_registration,
          submission: submission

        valid_attributes = {
          exercise_id: exercise.id,
          submission: {
            submission_assets_attributes: {
              '0' => {
                id: submission_asset.id,
                file: Rack::Test::UploadedFile.new(FactoryGirl.create(:submission_asset).file.to_s, 'text/html')
              }
            }
          }
        }

        submission.update! submitted_at: 42.days.ago

        expect do
          expect do
            expect do
              put :update, valid_attributes
            end.to change(SubmissionAsset, :count).by(0)
          end.to change(Submission, :count).by(0)

          submission.reload

        end.to change(submission, :submitted_at)

        expect(response).to redirect_to(exercise_student_submission_path(exercise))
      end
    end

    describe 'with invalid params' do
      # can not happen
    end
  end
end
