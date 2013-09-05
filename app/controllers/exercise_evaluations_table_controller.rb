class ExerciseEvaluationsTableController < ApplicationController
  def show
    respond_to do |format|
      format.html do
        @exercise = Exercise.find(params[:exercise_id])
        @term = @exercise.term
        @transposed = current_account.options[:transpose] || false
        @tutorial_groups = @term.tutorial_groups
      end
      format.json do
        if params[:transpose].present?
          current_account.options[:transpose] = (params[:transpose] == "true") || false
          current_account.save!
        end

        @exercise = Exercise.for_evaluations_table.find(params[:exercise_id])
        @term = @exercise.term

        @tutorial_group = if params[:tutorial_group_id].present?
          @term.tutorial_groups.find(params[:tutorial_group_id])
        else
          if tut_group = current_account.tutorial_groups.where(term: @term).first
            tut_group
          else
            @term.tutorial_groups.first
          end
        end

        @table_data = ExerciseEvaluationsTableData.new(@exercise, @tutorial_group, current_account.options[:transpose])
      end

    end
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
      @student_group = StudentGroup.find(params[:student_group_id])

      @term = @exercise.term

      @submission = @student_group.submissions.for_exercise(@exercise).first || begin
        s = Submission.new
        s.exercise = @exercise
        s.assign_to @student_group
        s.submitted_at = Time.now
        s.save!
        s
      end


      @rating = @exercise.ratings.find(params[:rating_id])

      @submission_evaluation = @submission.submission_evaluation
      @submission_evaluation.evaluated_at = Time.now
      @submission_evaluation.save!

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
