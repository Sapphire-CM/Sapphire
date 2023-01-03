class SubmissionTreeController < ApplicationController
  include ScopingHelpers
  include EventSourcing

  before_action :set_submission
  before_action :set_context
  before_action :set_tree
  before_action :set_directory

  def show
    @submission_upload = SubmissionUpload.new(submission: @submission)
    @submission_upload.path = params[:path] if params[:path].present?
  end

  def directory
    respond_to do |format|
      format.json
    end
  end

  def rename_folders

    # Attempting to rename the root directory 'submission'
    if @directory.parent == nil
      redirect_to tree_submission_path(@submission), alert: "Renaming root folder not allowed."
      return
    end

    if @directory.entries.any?
      render :'submission_folders/rename'
    else
      # Attempting to rename a directory not yet created
      redirect_to tree_submission_path(@submission),
                  alert: "Can not rename folder '#{params[:path]}'. Folder '#{params[:path]}' not created yet."
    end

  end

  def update_folder_name

    # renaming the directory with the name it already has
    if @directory.name == params[:new_directory_name]
      redirect_to tree_submission_path(@submission, @directory.parent.try(:path_without_root)),
                  notice: "Directory is already called '#{params[:path]}'."
      return
    end

    # renaming the directory with a taken name
    if @directory.parent.entries.any? { |e| e.name == params[:new_directory_name] }
      redirect_to tree_submission_path(@submission, @directory.parent.try(:path_without_root)),
                  alert: "The folder name '#{params[:new_directory_name]}' is already in use. Renaming '#{params[:path]}' was not successful."
      return
    end

    submission_assets = @submission.submission_assets.where(path: params[:path]).
      or(@submission.submission_assets.where("path like ?", "#{params[:path]}/%"))

    submission_assets.each do |asset|
      new_path = asset.path.sub(File.basename(params[:path]), params[:new_directory_name])
      asset.path = new_path
    end

    success = submission_assets.all? do |asset|
      asset.valid? && asset.save
    end

    if success
      event_service.submission_folder_renamed!(
        @submission,
        params[:path],
        params[:path].sub(File.basename(params[:path]), params[:new_directory_name]))
    end

    if success
      redirect_to tree_submission_path(@submission, @directory.parent.try(:path_without_root)),
                  notice:
                    "Successfully renamed directory '#{params[:path]}' to '#{params[:path].sub(File.basename(params[:path]), params[:new_directory_name])}'."
    else
      redirect_to tree_submission_path(@submission, @directory.parent.try(:path_without_root)),
                  alert: "The folder name '#{params[:new_directory_name]}' is already in use. Renaming '#{params[:path]}' was not successful."
    end

  end

  def destroy
    @parent_directory = @directory.parent
    submission_assets = @submission.submission_assets.inside_path(params[:path]).destroy_all

    if submission_assets.any?
      event_service.submission_assets_destroyed!(submission_assets)
    end

    redirect_to tree_submission_path(@submission, @parent_directory.try(:path_without_root)), notice: "Removed directory '#{params[:path]}'"
  end

  private
  def set_submission
    @submission = Submission.find(params[:id])
  end

  def set_context
    @exercise = @submission.exercise
    @term = @exercise.term
  end

  def set_tree
    @tree = @submission.tree

    authorize @tree
  end

  def set_directory
    @directory = @tree.resolve(params[:path])
  rescue SubmissionStructure::FileNotFound
    raise ActiveRecord::RecordNotFound
  end

  def directory_params
    params.require(:directory).permit(:name)
  end

end
