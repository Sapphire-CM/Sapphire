class SubmissionAssetsController < ApplicationController
  def show
    @submission_asset = SubmissionAsset.find(params[:id])
    authorize @submission_asset

    send_file(@submission_asset.file.current_path,
      filename: @submission_asset.file.identifier,
      type: @submission_asset.content_type.presence || 'application/octet-stream',
      disposition: :inline)
  end
end
