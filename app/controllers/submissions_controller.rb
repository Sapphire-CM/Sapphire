class SubmissionsController < ApplicationController
  def show
    set_submission

    redirect_to tree_submission_path(@submission)
  end

  def edit
    set_submission
    set_context
  end

  def update
    set_submission

    @submission.assign_attributes(submission_params)
    @submission.set_exercise_of_exercise_registrations!

    if @submission.save
      redirect_to edit_submission_path(@submission), notice: "Successfully updated submission"
    else
      set_context

      render :edit
    end
  end

  private
  def set_submission
    @submission = Submission.find(params[:id])

    authorize @submission
  end

  def set_context
    @exercise = @submission.exercise
    @term = @exercise.term
  end

  def submission_params
    params.require(:submission).permit(:student_group_id, exercise_registrations_attributes: [:id, :_destroy, :individual_subtractions, :term_registration_id])
  end
end
