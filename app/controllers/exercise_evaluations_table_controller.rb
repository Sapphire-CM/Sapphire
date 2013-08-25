class ExerciseEvaluationsTableController < TermResourceController
  def show
    @exercise = current_term.exercises.includes(submissions: {submission_evaluation: {evaluation_groups: [:rating_group, {evaluations: :rating}]}}).find(params[:exercise_id])
    @table_data = ExerciseEvaluationsTableData.new(@exercise, current_term.tutorial_groups.first)
  end

  def create
    update_evaluation
  end

  def update
    update_evaluation
  end

  private
  def update_evaluation
    @exercise = Exercise.find(params[:exercise_id])
    @submission = @exercise.submissions.find(params[:submission_id])
    @rating = @exercise.ratings.find(params[:rating_id])

    @submission_evaluation = if @submission.submission_evaluation.present?
      @submission.submission_evaluation
    else
      se = SubmissionEvaluation.new
      se.submission = @submission
      se.evaluator = current_account
      se.evaluated_at = Time.now
      se.save!
      @update_all_evaluation_groups = true

      se
    end

    @student_group = @submission.student_group
    @evaluation = Evaluation.where(rating_id: @rating.id).for_submission(@submission).first

    if @evaluation.update_attributes(evaluation_params)
      respond_to do |format|
        format.js
      end
    else
      render :text, "alert('something went wrong!')"
    end
  end


  def evaluation_params
    params.require(:evaluation).permit(:value)
  end
end
