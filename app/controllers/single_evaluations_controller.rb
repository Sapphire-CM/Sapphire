class SingleEvaluationsController < ApplicationController
  include ScopingHelpers

  SingleEvaluationPolicyRecord = Struct.new :submission do
    def policy_class
      SingleEvaluationPolicy
    end
  end

  before_action :set_submission_and_tutorial_group, only: :show

  def show
    @submission = Submission.find(params[:id])
    authorize SingleEvaluationPolicyRecord.new @submission

    @submission_assets = @submission.submission_assets.order(submitted_at: :desc)

    submission_scope = scoped_submissions(@tutorial_group, Submission.for_exercise(@submission.exercise))

    @previous_submission = submission_scope.next(@submission, :submitted_at)
    @next_submission = submission_scope.previous(@submission, :submitted_at)

    @exercise = @submission.exercise
    @evaluation_groups = @submission.submission_evaluation.evaluation_groups.includes([:rating_group, {evaluations: :rating}]).order{rating_group.ratings.row_order.asc}.order{rating_group.row_order.asc}
    @term = @exercise.term
  end

  def update
    @evaluation = Evaluation.find(params[:id])
    @submission = @evaluation.submission
    authorize SingleEvaluationPolicyRecord.new @submission

    @rating = @evaluation.rating

    @evaluation.value = if @rating.is_a? BinaryRating
      @evaluation.value == 1 ? 0 : 1
    else
      params.require(:evaluation).permit(:value)[:value]
    end
    @evaluation.save!

    @submission_evaluation = @submission.submission_evaluation
    @submission_evaluation.evaluated_at = Time.now
    @submission_evaluation.save!
  end

  private
  def set_submission_and_tutorial_group
    @submission = Submission.find(params[:id])
    @term = @submission.exercise.term
    @tutorial_group = current_tutorial_group(@term)
  end
end
