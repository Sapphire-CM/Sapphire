class SubmissionAssets::MovesController < ApplicationController
  include EventSourcing
  before_action :set_context

  def move
    authorize @submission_asset
    current_path = @submission_asset.path
    @submission_asset.path = params[:target_path]

    if @submission_asset.save
      flash[:notice] = "Successfully moved file '#{@submission_asset.filename}' to '#{params[:target_path]}'."
      render json: { redirect_url: tree_submission_path(@submission_asset.submission, path: current_path) }, status: :ok
    else
      flash[:error] = "Failed to move file '#{@submission_asset.filename}'."
      render json: { error: 'Failed to move file', redirect_url: tree_submission_path(@submission_asset.submission, path: current_path),  }, status: :ok
    end
  end


  private

  def set_context
    @submission_asset = SubmissionAsset.find(params[:submission_asset_id])
    @term = @submission_asset.submission.term
    @submission = @submission_asset.submission
  end

end
