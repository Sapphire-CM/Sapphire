class SubmissionViewersController < ApplicationController
  def show
    @submission = Submission.find(params[:id])
    @viewer = Sapphire::SubmissionViewers::Central.viewer_for_submission(@submission)


    if @viewer

    else
      redirect_to single_evaluation_path(@submission), alert: "There is no viewer for this submission"
    end
  end
end
