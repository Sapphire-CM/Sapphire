require 'rails_helper'
require 'base64'

RSpec.describe StudentSubmissionsController do
  render_views
  include_context 'active_student_session_context'

  describe 'GET show' do
    let(:term_registration) { current_account.term_registrations.first }
    let(:term) { term_registration.term }
    let(:exercise) { FactoryBot.create :exercise, term: term }
    let(:submission) { FactoryBot.create(:submission, exercise: exercise) }

    it 'redirects to the new submission page if it does not yet exist' do
      get :show, params: { exercise_id: exercise.id }

      expect(response).to redirect_to(new_exercise_student_submission_path(exercise))
    end

    it 'redirects to the submission_tree page if it already exists' do
      exercise_registration = FactoryBot.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission)

      get :show, params: { exercise_id: exercise.id }
      expect(response).to redirect_to(submission_path(submission))
    end
  end

  describe 'GET new' do
    let(:term_registration) { current_account.term_registrations.first }
    let(:term) { term_registration.term }
    let(:tutorial_group) { term_registration.tutorial_group }
    let(:exercise) { FactoryBot.create :exercise, term: term }

    it 'assigns @exercise, @term and @student_group for group submissions' do
      student_group = FactoryBot.create(:student_group, tutorial_group: tutorial_group)
      term_registration.update(student_group: student_group)

      get :new, params: { exercise_id: exercise.id }

      expect(assigns[:exercise]).to eq(exercise)
      expect(assigns[:term]).to eq(term)
      expect(assigns[:student_group]).to eq(student_group)
    end

    it 'redirects to the submission_tree page if it already exists' do
      submission = FactoryBot.create(:submission, exercise: exercise)
      exercise_registration = FactoryBot.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission)

      get :show, params: { exercise_id: exercise.id }
      expect(response).to redirect_to(submission_path(submission))
    end
  end

  describe 'POST create' do
    let(:term_registration) { current_account.term_registrations.first }
    let(:term) { term_registration.term }
    let(:tutorial_group) { term_registration.tutorial_group }
    let(:exercise) { FactoryBot.create :exercise, term: term }

    it 'creates a submission and assigns it to @submission' do
      expect_any_instance_of(SubmissionCreationService).to receive(:save).and_call_original
      expect do
        post :create, params: { exercise_id: exercise.id }
      end.to change(Submission, :count).by(1)

      expect(assigns[:submission]).to be_present
      expect(response).to redirect_to(submission_path(assigns[:submission]))
    end

    it 'renders #new if the submission could not be created' do
      allow_any_instance_of(SubmissionCreationService).to receive(:save).and_return(false)

      expect do
        post :create, params: { exercise_id: exercise.id }
      end.not_to change(Submission, :count)

      expect(assigns[:submission]).to be_present
      expect(response).to render_template("new")
    end

    it 'redirects to the submission_tree page if it already exists' do
      submission = FactoryBot.create(:submission, exercise: exercise)
      exercise_registration = FactoryBot.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission)

      get :show, params: { exercise_id: exercise.id }
      expect(response).to redirect_to(submission_path(submission))
    end
  end
end
