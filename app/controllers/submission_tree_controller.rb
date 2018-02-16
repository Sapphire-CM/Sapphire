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
end
