class SubmissionEvaluationsController < ApplicationController
  layout "evaluations"

  def show
    set_submission_evaluation
    set_submission
    set_exercise
    set_term
  end

  private
  def set_submission_evaluation
    @submission_evaluation = SubmissionEvaluation.find(params[:id])

    authorize(@submission_evaluation)
  end

  def set_submission
    @submission = @submission_evaluation.submission
  end

  def set_exercise
    @exercise = @submission.exercise
  end

  def set_term
    @term = @exercise.term
  end
end
