class SubmissionAssetsRenamesController < ApplicationController
  include EventSourcing
  before_action :set_context
  def new
    @rename = SubmissionAssetRename.new(
      renamed_at: Time.now.strftime("%Y-%m-%d %H:%M"),
      filename_old:  @submission_asset.filename,
      submission_asset: @submission_asset,
      submission: @submission
      )
    authorize @rename
  end

  def create
    @rename = SubmissionAssetRename.new({
                                               renamed_at: Time.now.strftime("%Y-%m-%d %H:%M"),
                                               filename_old:  @submission_asset.filename,
                                               renamed_by: current_account
                                           }.merge(rename_params))
    @rename.submission_asset = @submission_asset
    @rename.submission = @submission
    authorize @rename

    if @rename.save!
      event_service.submission_asset_renamed!(@rename)
      redirect_to tree_submission_path(@submission_asset.submission, path: @submission_asset.path), notice: "Successfully renamed submission file"
    else
      redirect_to tree_submission_path(@submission_asset.submission, path: @submission_asset.path),
                  alert: "Error renaming submission file: invalid filename"
    end
  end

  private

  def set_context
    @submission_asset = SubmissionAsset.find(params[:id])
    @term = @submission_asset.submission.term
    @submission = @submission_asset.submission
  end

  def rename_params
    params.require(:submission_asset_rename).permit(:new_filename)
  end

end
