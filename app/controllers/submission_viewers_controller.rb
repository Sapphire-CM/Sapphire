class SubmissionViewersController < ApplicationController
  SubmissionViewerPolicyRecord = Struct.new :submission do
    def policy_class
      SubmissionViewerPolicy
    end
  end

  def show
    @submission = Submission.find(params[:id])
    authorize SubmissionViewerPolicyRecord.new @submission

    @viewer = Sapphire::SubmissionViewers::Central.viewer_for_submission(@submission, params)

    if @viewer
      @viewer.params = params
    else
      redirect_to single_evaluation_path(@submission), alert: "There is no viewer for this submission"
    end
  end
end
