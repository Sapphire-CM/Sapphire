require 'rails_helper'

RSpec.describe StudentResultsController do
  render_views
  include_context 'active_student_session_context'

  let(:term) { FactoryGirl.create :term }
  let(:exercise) { FactoryGirl.create :exercise, term: term }
  let(:tutorial_group) { FactoryGirl.create :tutorial_group, term: term }
  let(:submission) { FactoryGirl.create :submission, exercise: exercise }
  let(:term_registration) { current_account.term_registrations.first }

  before :each do
    term_registration.update! term: term, tutorial_group: tutorial_group
    exercise.result_publications.update_all published: true
  end

  describe 'GET index' do
    it 'assigns all exercise_registrations as @exercise_registrations' do
      FactoryGirl.create_list :course, 4

      get :index, term_id: term.id

      expect(response).to have_http_status(:success)
      expect(assigns(:exercise_registrations)).to match_array(term_registration.exercise_registrations)
    end
  end

  describe 'GET show' do
    context 'when a submission exists' do
      it 'assigns the requested submission as @submission' do
        SubmissionCreationService.new(current_account, submission).save

        get :show, term_id: term.id, id: exercise.id

        expect(response).to have_http_status(:success)
        expect(assigns[:submission]).to eq(submission)
        expect(assigns[:submission_evaluation]).to eq(submission.submission_evaluation)
        expect(assigns[:term]).to eq(term)
        expect(assigns[:exercise]).to eq(exercise)
      end
    end

    context 'when no submission exists' do
      it 'redirects to submission path' do
        get :show, id: exercise.id, term_id: term.id

        expect(response).to redirect_to(exercise_student_submission_path(exercise))
      end
    end
  end
end
