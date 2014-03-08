class SingleEvaluationsController < ApplicationController
  def show
    @submission = Submission.find(params[:id])
    authorize @submission

    @submission_assets = @submission.submission_assets.order(submitted_at: :desc)

    submission_scope = Submission.for_exercise(@submission.exercise).for_tutorial_group(@submission.student_group.tutorial_group)
    @next_submission = submission_scope.next(@submission, :submitted_at)
    @previous_submission = submission_scope.previous(@submission, :submitted_at)

    @exercise = @submission.exercise
    @evaluation_groups = @submission.submission_evaluation.evaluation_groups.includes([:rating_group, {evaluations: :rating}]).order{rating_group.ratings.row_order.asc}.order{rating_group.row_order.asc}
    @term = @exercise.term
  end

  def update
    @evaluation = Evaluation.find(params[:id])
    authorize @evaluation

    @rating = @evaluation.rating

    @evaluation.value = if @rating.is_a? BinaryRating
      @evaluation.value == 1 ? 0 : 1
    else
      params.require(:evaluation).permit(:value)[:value]
    end
    @evaluation.save!

    @submission = @evaluation.submission

    @submission_evaluation = @submission.submission_evaluation
    @submission_evaluation.evaluated_at = Time.now
    @submission_evaluation.save!
  end
end
