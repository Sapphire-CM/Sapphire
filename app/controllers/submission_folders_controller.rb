class SubmissionFoldersController < ApplicationController
  before_action :set_submission

  def show
    @submission_folder = SubmissionFolder.new(folder_params)
    @submission_folder.submission = @submission

    authorize @submission_folder

    respond_to do |f|
      f.json
    end
  end

  def new
    @submission_folder = SubmissionFolder.new(submission: @submission)

    authorize @submission_folder

    @exercise = @submission.exercise
    @term = @exercise.term
  end

  def create
    @folder = SubmissionFolder.new(folder_params)
    @folder.submission = @submission
    authorize @folder

    redirect_to tree_submission_path(@submission, path: @folder.full_path)
  end

  private
  def set_submission
    @submission = Submission.find(params[:submission_id])
  end

  def folder_params
    params.require(:submission_folder).permit(:path, :name)
  end
end
