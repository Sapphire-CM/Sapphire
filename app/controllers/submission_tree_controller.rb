class SubmissionTreeController < ApplicationController
  include ScopingHelpers
  include EventSourcing

  before_action :set_submission
  before_action :set_context

  def show
    @tree = @submission.tree(params[:path])

    @submission_upload = SubmissionUpload.new(submission: @submission)
    @submission_upload.path = params[:path] if params[:path].present?
  end

  def directory
    @tree = @submission.tree(params[:path])

    respond_to do |format|
      format.json
    end
  end

  def destroy
    @parent_directory = @submission.tree(params[:path]).parent
    submission_assets = @submission.submission_assets.inside_path(params[:path]).destroy_all

    if submission_assets.any?
      event_service.submission_assets_destroyed!(submission_assets)
    end

    redirect_to tree_submission_path(@submission, @parent_directory.path_without_root), notice: "Removed directory '#{params[:path]}'"
  end

  private
  def set_submission
    @submission = Submission.find(params[:id])
    authorize @submission
  end

  def set_context
    @exercise = @submission.exercise
    @term = @exercise.term
  end
end
