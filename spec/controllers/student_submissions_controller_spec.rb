require 'rails_helper'
require 'base64'

RSpec.describe StudentSubmissionsController do
  render_views
  include_context 'active_student_session_context'

  describe 'GET show' do
    let(:term_registration) { current_account.term_registrations.first }
    let(:term) { term_registration.term }
    let(:exercise) { FactoryGirl.create :exercise, term: term }
    let(:submission) { FactoryGirl.create(:submission, exercise: exercise) }

    it 'redirects to the new submission page if it does not yet exist' do
      get :show, exercise_id: exercise.id

      expect(response).to redirect_to(new_exercise_student_submission_path(exercise))
    end

    it 'redirects to the submission_tree page if it already exists' do
      exercise_registration = FactoryGirl.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission)

      get :show, exercise_id: exercise.id
      expect(response).to redirect_to(submission_path(submission))
    end
  end

  describe 'GET new' do
    let(:term_registration) { current_account.term_registrations.first }
    let(:term) { term_registration.term }
    let(:tutorial_group) { term_registration.tutorial_group }
    let(:exercise) { FactoryGirl.create :exercise, term: term }

    it 'assigns @exercise, @term and @student_group for group submissions' do
      student_group = FactoryGirl.create(:student_group, tutorial_group: tutorial_group)
      term_registration.update(student_group: student_group)

      get :new, exercise_id: exercise.id

      expect(assigns[:exercise]).to eq(exercise)
      expect(assigns[:term]).to eq(term)
      expect(assigns[:student_group]).to eq(student_group)
    end

    it 'redirects to the submission_tree page if it already exists' do
      submission = FactoryGirl.create(:submission, exercise: exercise)
      exercise_registration = FactoryGirl.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission)

      get :show, exercise_id: exercise.id
      expect(response).to redirect_to(submission_path(submission))
    end
  end

  describe 'POST create' do
    let(:term_registration) { current_account.term_registrations.first }
    let(:term) { term_registration.term }
    let(:tutorial_group) { term_registration.tutorial_group }
    let(:exercise) { FactoryGirl.create :exercise, term: term }

    it 'creates a submission and assigns it to @submission' do
      expect do
        post :create, exercise_id: exercise.id
      end.to change(Submission, :count).by(1)

      expect(assigns[:submission]).to be_present
      expect(response).to redirect_to(submission_path(assigns[:submission]))
    end

    it 'redirects to the submission_tree page if it already exists' do
      submission = FactoryGirl.create(:submission, exercise: exercise)
      exercise_registration = FactoryGirl.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission)

      get :show, exercise_id: exercise.id
      expect(response).to redirect_to(submission_path(submission))
    end
  end
end
