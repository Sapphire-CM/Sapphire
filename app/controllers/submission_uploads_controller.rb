class SubmissionUploadsController < ApplicationController
  before_action :set_submission
  before_action :set_context

  def new
    @submission_upload = SubmissionUpload.new(submission: @submission)
    @submission_upload.path = params[:path] if params[:path].present?
    authorize @submission_upload
  end

  def create
    @submission_upload = SubmissionUpload.new(submission_upload_params)
    @submission_upload.submission = @submission

    authorize @submission_upload

    if @submission_upload.save
      respond_to do |format|
        format.html {redirect_to new_submission_upload_path(@submission, path: @submission_upload.path.presence), notice: "Successfully added #{@submission_upload.submission_asset.filename}"}
        format.json
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json
      end
    end
  end

  private
  def submission_upload_params
    params.require(:submission_upload).permit(:path, :file)
  end

  def set_submission
    @submission = Submission.find(params[:submission_id])
  end

  def set_context
    @exercise = @submission.exercise
    @term = @exercise.term
  end
end
