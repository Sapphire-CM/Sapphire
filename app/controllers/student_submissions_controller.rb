class StudentSubmissionsController < ApplicationController
  include EventSourcing

  before_action :set_exercise_and_term
  before_action :set_submission

  def show
    redirect_to new_exercise_student_submission_path(@exercise)
  end

  def new
    @student_group = StudentGroup.for_account(current_account).for_term(@term).first
  end

  def create
    authorize @submission
    @submission.save

    redirect_to submission_path(@submission)
  end

  private

  def set_exercise_and_term
    @exercise = Exercise.find params[:exercise_id]
    @term = @exercise.term
  end

  def set_submission
    @submission = Submission.find_by_account_and_exercise(current_account, @exercise)

    if @submission.present?
      authorize @submission

      redirect_to submission_path(@submission)
    else
      @submission = SubmissionCreationService.initialize_empty_submission(current_account, @exercise)

      authorize @submission
    end
  end

  def submission_params
    params.require(:submission).permit(submission_assets_attributes: [:id, :file, :_destroy])
  end
end
