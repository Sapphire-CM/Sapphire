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

    if @submission_creation_service.save
      redirect_to submission_path(@submission)
    else
      render :new, alert: "Could not create submission"
    end
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
      @submission_creation_service = SubmissionCreationService.new_with_exercise(current_account, @exercise)

      @submission = @submission_creation_service.model
      authorize @submission
    end
  end
end
