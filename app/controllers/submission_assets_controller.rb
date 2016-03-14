class SubmissionAssetsController < ApplicationController
  def show
    @submission_asset = SubmissionAsset.find(params[:id])
    authorize @submission_asset

    send_file(@submission_asset.file.current_path,
      filename: @submission_asset.file.identifier,
      type: @submission_asset.content_type.presence || 'application/octet-stream',
      disposition: :inline)
  end

  def destroy
    @submission_asset = SubmissionAsset.find(params[:id])
    authorize @submission_asset

    @submission_asset.destroy

    redirect_to tree_submission_path(@submission_asset.submission, path: @submission_asset.path), notice: "File successfully removed"
  end
end
