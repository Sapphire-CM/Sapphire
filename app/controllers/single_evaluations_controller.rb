class SingleEvaluationsController < ApplicationController
  include ScopingHelpers

  def show
    @submission = Submission.find(params[:id])
    authorize SingleEvaluationPolicy.with @submission

    @term = @submission.exercise.term
    @tutorial_group = current_tutorial_group(@term)
    @submission_assets = @submission.submission_assets.order(submitted_at: :desc)

    submission_scope = scoped_submissions(@tutorial_group, Submission.for_exercise(@submission.exercise))

    @previous_submission = submission_scope.next(@submission, :submitted_at)
    @next_submission = submission_scope.previous(@submission, :submitted_at)

    @exercise = @submission.exercise
    @term = @exercise.term
    @evaluation_groups = @submission.submission_evaluation.evaluation_groups
  end
end
