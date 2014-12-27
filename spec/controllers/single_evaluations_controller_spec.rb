require 'rails_helper'

RSpec.describe SingleEvaluationsController do
  render_views
  include_context 'active_admin_session_context'

  let(:term) { FactoryGirl.create :term }
  let(:exercise) { FactoryGirl.create :exercise, :with_ratings, term: term }
  let(:submission) { FactoryGirl.create_list(:submission, 3, exercise: exercise)[1] }
  let(:submission_evaluation) { submission.submission_evaluation }
  let(:evaluation) { submission_evaluation.evaluations.first }

  describe 'GET show' do
    it 'assigns the requested submission as @submission' do
      get :show, id: submission.id

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
      expect(assigns(:exercise)).to eq(exercise)
      expect(assigns(:submission)).to eq(submission)
      expect(assigns(:previous_submission)).to be_a(Submission) if assigns(:previous_submission)
      expect(assigns(:next_submission)).to be_a(Submission) if assigns(:next_submission)
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested term' do
        submission_evaluation.update! updated_at: 42.days.ago

        expect {
          xhr :put, :update, id: evaluation.id
          submission_evaluation.reload
        }.to change(submission_evaluation, :updated_at)

        expect(response).to have_http_status(:success)
        expect(assigns(:evaluation)).to eq(evaluation)
        expect(assigns(:submission)).to eq(submission)
        expect(assigns(:submission_evaluation)).to eq(submission_evaluation)
      end
    end

    describe 'with invalid params' do
      # can not happen
    end
  end
end
