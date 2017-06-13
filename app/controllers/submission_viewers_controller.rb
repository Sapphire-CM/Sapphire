class SubmissionViewersController < ApplicationController
  def show
    @submission = Submission.find(params[:id])
    authorize SubmissionViewerPolicy.with @submission

    @viewer = Sapphire::SubmissionViewers::Central.viewer_for_submission(@submission, params)

    if @viewer
      @viewer.params = params
    else
      redirect_to submission_evaluation_path(@submission.submission_evaluation), alert: 'There is no viewer for this submission'
    end
  end
end
