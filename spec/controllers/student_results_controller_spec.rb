require 'rails_helper'

describe StudentResultsController do
  context "GET #show" do
    before :each do
      sign_in(user)
    end

    let(:perform_action) {
      get :show, id: exercise.id, term_id: term.id
    }

    context "as a student" do
      let(:user) {
        user = create(:account)
        FactoryGirl.create(:term_registration, :student, account: user, term: term, tutorial_group: tutorial_group)
        user
      }

      let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
      let(:term) { FactoryGirl.create(:term) }

      let(:course) { term.course }
      let(:exercise) {
        exercise = create(:exercise, term: term)
        exercise.result_publications.update_all(published: true)
        exercise
      }

      context "when a submission exists" do
        let(:submission) {
          submission = create(:submission, exercise: exercise)
          scs = SubmissionCreationService.new(user, submission)
          scs.save

          submission
        }
        let(:submission_evaluation) { submission.submission_evaluation }

        before :each do
          submission
        end

        it "should assign @submission" do
          perform_action
          expect(assigns[:submission]).to eq(submission)
        end

        it "should assign @submission_evaluation" do
          perform_action
          expect(assigns[:submission_evaluation]).to eq(submission_evaluation)
        end

        it "should assign @term" do
          perform_action
          expect(assigns[:term]).to eq(term)
        end

        it "should assign @exercise" do
          perform_action
          expect(assigns[:exercise]).to eq(exercise)
        end
      end

      context "when no submission exists" do
        it "should redirect to submission path" do
          perform_action
          expect(response).not_to be_ok
        end
      end
    end
  end
end
