require 'spec_helper'

describe StudentResultsController do
  before :each do
    sign_in(user)
  end

  context "GET #show" do
    context "as a student" do
      let(:user) { create(:account, :student) }
      let(:term) { user.student_registrations.first.term}
      let(:student_group) { user.student_groups.first }
      let(:student_group_registration) { student_group.register_for(exercise) }
      let(:tutorial_group) { student_group.tutorial_group}
      let(:course) { term.course }
      let(:exercise) { create(:exercise, term: term)}

      context do
        let(:perform_action) { get :show, exercise_id: exercise }

        context "when a submission exists" do
          let(:submission) { create(:submission, exercise: exercise, student_group_registration: student_group_registration)}
          let(:submission_evaluation) { submission.submission_evaluation}


          before :each do
            @submission = submission
          end

          it "should assign @submission" do
            perform_action
            expect(assigns[:submission]).to eq(@submission)
          end

          it "should assign @submission_evaluation" do
            perform_action
            expect(assigns[:submission_evaluation]).to eq(@submission.submission_evaluation)
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
            expect(response).to redirect_to(exercise_student_submission_path(exercise))
          end
        end
      end
    end
  end
end
