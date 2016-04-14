class SubmissionFoldersController < ApplicationController
  before_action :set_submission

  def show
    @folder = SubmissionFolder.new(folder_params)
    @folder.submission = @submission

    respond_to do |f|
      f.json
    end
  end

  def create
    folder = SubmissionFolder.new(folder_params)

    redirect_to tree_submission_path(@submission, path: folder.full_path)
  end


  private
  def set_submission
    @submission = Submission.find(params[:submission_id])

    authorize @submission
  end

  def folder_params
    params.require(:submission_folder).permit(:path, :name)
  end
end
