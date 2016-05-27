class SubmissionsController < ApplicationController
  before_action :set_submission, only: :show

  def show
    redirect_to tree_submission_path(@submission)
  end

  private
  def set_submission
    @submission = Submission.find(params[:id])

    authorize @submission
  end
end
