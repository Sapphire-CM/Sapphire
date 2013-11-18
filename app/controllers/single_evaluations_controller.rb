class SingleEvaluationsController < ApplicationController
  def show
    @submission = Submission.find(params[:id])

    @next_submission = Submission.for_exercise(@submission.exercise).for_tutorial_group(@submission.student_group.tutorial_group).next(@submission)
    @previous_submission = Submission.for_exercise(@submission.exercise).for_tutorial_group(@submission.student_group.tutorial_group).previous(@submission)

    @exercise = @submission.exercise
    @evaluation_groups = @submission.submission_evaluation.evaluation_groups.includes([:rating_group, {evaluations: :rating}])
    @term = @exercise.term
  end

  def update
    @evaluation = Evaluation.find(params[:id])
    @rating = @evaluation.rating
    @evaluation.value = if @rating.is_a? BinaryRating
      @evaluation.value == 1 ? 0 : 1
    else
      params.require(:evaluation).permit(:value)[:value]
    end
    @evaluation.save

    @submission = @evaluation.submission

    @submission_evaluation = @submission.submission_evaluation
    @submission_evaluation.evaluated_at = Time.now
    @submission_evaluation.save
  end
end
