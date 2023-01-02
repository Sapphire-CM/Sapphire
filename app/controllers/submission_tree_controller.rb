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
    render :'submission_folders/rename'
  end

  def update_folder_name
    if @directory.parent.entries.any? { |e| e.name == params[:new_directory_name] }
      redirect_to tree_submission_path(@submission, @directory.parent.try(:path_without_root)),
                  alert: "The folder name '#{params[:new_directory_name]}' is already in use. Renaming '#{params[:path]}' was not successful."
      return
    end

    submission_assets = @submission.submission_assets.where(path: params[:path]).
      or(@submission.submission_assets.where("path like ?", "#{params[:path]}/%"))

    submission_assets.each do |asset|
      asset.path = asset.path.sub(File.basename(params[:path]), params[:new_directory_name])
      asset.save
    end

    success = submission_assets.all? { |asset| asset.save }

    if success
      redirect_to tree_submission_path(@submission, @directory.parent.try(:path_without_root)),
                  notice: "Successfully renamed directory '#{params[:path]}' to '#{params[:new_directory_name]}'."
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
