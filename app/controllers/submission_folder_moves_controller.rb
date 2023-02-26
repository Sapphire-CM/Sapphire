require 'pathname'
class SubmissionFolderMovesController < ApplicationController
  include EventSourcing

  before_action :set_context

  def move
    authorize @tree
    source_path = Pathname.new(params[:submission_asset_id])
    source_path_basename = File.basename(source_path)

    target_path = Pathname.new(params[:target_path])
    target_path_basename = File.basename(target_path)

    new_directory_path = target_path.join(source_path_basename)

    if source_path == target_path then # moving folder to itself
      #flash[:error] = "Failed to move folder '#{source_basename}': A folder named '#{source_basename}' already exist in '#{target_last_segment}'."
      #render json: { error: 'Failed to move file', redirect_url: tree_submission_path(@submission, path:  @directory.parent.try(:path_without_root)),  }, status: :ok
      return
    end

    submission_assets = @submission.submission_assets.where(path: source_path.to_s).
      or(@submission.submission_assets.where("path like ?", "#{source_path.to_s}/%"))

    # moving folder to a folder where a folder with the same name already exist
    if @tree.resolve(new_directory_path).entries.any?
      flash[:error] = "Failed to move folder '#{source_path_basename}': A folder named '#{source_path_basename}' already exist in '#{target_path}'."
      render json: { error: 'Failed to move file', redirect_url: tree_submission_path(@submission, path:  @directory.parent.try(:path_without_root)),  }, status: :ok
      return
    end

    submission_assets.each do |asset|
      asset_path = Pathname.new(asset.path)
      relative_asset_path = asset_path.relative_path_from(source_path)
      new_asset_path = new_directory_path.join(relative_asset_path)
      asset.path = new_asset_path
    end

    success = submission_assets.all? do |asset|
      asset.valid? && asset.save
    end

    if success
      flash[:notice] = "Successfully moved file '#{source_path_basename.to_s}' to #{ target_path_basename.to_s.empty? ? 'root directory' : "''" + target_path.to_s + "''"}."
      render json: { redirect_url: tree_submission_path(@submission, path: @directory.parent.path_without_root) }, status: :ok
    else
      flash[:error] = "Failed to move file '#{source_path}'."
      render json: { error: 'Failed to move file', redirect_url: tree_submission_path(@submission, path:  @directory.parent.try(:path_without_root)),  }, status: :ok
    end
  end


  private

  def set_context
    @submission = Submission.find(params[:submission_id])
    @tree = @submission.tree
    print(params[:submission_asset_id])
    @directory = @tree.resolve(params[:submission_asset_id])
  rescue SubmissionStructure::FileNotFound
    raise ActiveRecord::RecordNotFound
  end

end
