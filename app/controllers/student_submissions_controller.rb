require 'zip'
require 'base64'

class StudentSubmissionsController < ApplicationController
  include EventSourcing

  before_action :set_exercise_and_term
  before_action :set_submission, only: [:show, :update, :catalog, :extract, :tree]
  before_action :ensure_submission_param, only: [:create, :update]

  skip_after_action :verify_authorized, only: :create, if: lambda { params[:submission].blank? }

  def show
    if @submission
      authorize @submission

      redirect_to submission_path(@submission)
    else
      @submission = SubmissionCreationService.initialize_empty_submission(current_account, @exercise)
      authorize @submission, :create?
      @submission.save

      redirect_to submission_upload_path(@submission)
    end
  end

  private

  def set_exercise_and_term
    @exercise = Exercise.find params[:exercise_id]
    @term = @exercise.term
  end

  def set_submission
    @submission = Submission.find_by_account_and_exercise(current_account, @exercise)
  end

  def submission_params
    params.require(:submission).permit(submission_assets_attributes: [:id, :file, :_destroy])
  end
end
