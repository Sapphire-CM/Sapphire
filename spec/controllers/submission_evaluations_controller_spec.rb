require 'rails_helper'

RSpec.describe SubmissionEvaluationsController, type: :controller do
  render_views
  include_context 'active_admin_session_context'

  let(:term) { FactoryBot.create :term }
  let(:exercise) { FactoryBot.create :exercise, :with_ratings, term: term }
  let(:rating_group) { exercise.rating_groups.first }

  let(:submission) { FactoryBot.create_list(:submission, 3, exercise: exercise)[1] }
  let(:submission_evaluation) { submission.submission_evaluation }

  describe 'GET show' do
    it 'assigns the requested submission as @submission' do
      get :show, params: { id: submission_evaluation.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
      expect(assigns(:exercise)).to eq(exercise)
      expect(assigns(:submission)).to eq(submission)
    end

    context 'as a tutor' do
      let(:tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }
      let(:tutor_registration) { FactoryBot.create(:term_registration, :tutor, term: term, tutorial_group: tutorial_group) }

      it 'returns a successful response' do
        sign_in(tutor_registration.account)

        get :show, params: { id: submission_evaluation.id }

        expect(response).to have_http_status(:success)
      end
    end
  end
end
