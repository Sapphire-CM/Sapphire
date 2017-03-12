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

  def update
    @evaluation = Evaluation.find(params[:id])
    @submission = @evaluation.submission
    authorize SingleEvaluationPolicy.with @submission

    @rating = @evaluation.rating

    @evaluation.value = if @rating.is_a? Ratings::FixedRating
      @evaluation.value == 1 ? 0 : 1
    else
      params[:evaluation][:value]
    end

    @submission_evaluation = @submission.submission_evaluation

    if @evaluation.save
      @submission_evaluation.reload
      @submission_evaluation.update(evaluated_at: Time.now)
    else
      render :update_error
    end
  end
end
