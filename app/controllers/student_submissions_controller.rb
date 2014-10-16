class StudentSubmissionsController < ApplicationController
  SubmissionPolicyRecord = Struct.new :exercise, :tutorial_group do
    def policy_class
      SubmissionPolicy
    end
  end

  before_action :set_exercise_and_term
  before_action :set_submission, only: [:show, :update]
  before_action :ensure_submission_param, only: [:create, :update]

  skip_after_action :verify_authorized, only: :create, if: lambda { params[:submission].blank? }

  def show
    unless current_account.student_of_term? @term
      redirect_to exercise_submissions_path(@exercise)
      return
    end

    @term = @submission.exercise.term
    @submission_assets = @submission.submission_assets
  end

  def create
    creation_service = SubmissionCreationService.new_with_params(current_account, @exercise, submission_params)
    authorize creation_service.model

    if creation_service.save
      if policy(@term).student?
        redirect_to exercise_student_submission_path(@exercise), notice: "Successfully uploaded submission"
      end
    else
      render :show
    end
  end

  def update
    @submission.assign_attributes(submission_params)
    @submission.submitted_at = Time.now

    if @submission.save
      if policy(@term).student?
        redirect_to exercise_student_submission_path(@exercise), notice: "Successfully updated submission"
      end
    else
      render :show
    end
  end

  private
  def submission_params
    params.require(:submission).permit(submission_assets_attributes: [:id, :file])
  end

  def ensure_submission_param
    redirect_to exercise_student_submission_path(@exercise), notice: "Please choose a file to upload" unless params[:submission].present?
  end

  def set_exercise_and_term
    @exercise = Exercise.find params[:exercise_id]
    @term = @exercise.term
  end

  def set_submission
    @submission = Submission.select(Submission.quoted_table_name + '.*').for_account(current_account).for_exercise(@exercise).first_or_initialize

    authorize @submission
  end
end
