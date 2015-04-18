class SubmissionAssetsController < ApplicationController
  def show
    @submission_asset = SubmissionAsset.find(params[:id])
    authorize @submission_asset

    send_file(@submission_asset.file.current_path,
      filename: @submission_asset.file.identifier,
      type: @submission_asset.content_type || 'application/octet-stream',
      disposition: :inline)
  end

  def new
    @submission_asset = SubmissionAsset.new
    @submission_asset.submission = Submission.find(params[:submission_id])
    authorize @submission_asset
  end

  def create
    @submission_asset = SubmissionAsset.new(submission_assets_params)
    @submission_asset.content_type = submission_assets_params[:file].content_type
    authorize @submission_asset

    if @submission_asset.save
      render :create
    else
      render :new
    end
  end

  private

  def submission_assets_params
    params.require(:submission_asset).permit(
      :file,
      :submission_id)
  end
end
