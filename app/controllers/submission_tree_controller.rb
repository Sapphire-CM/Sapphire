class SubmissionTreeController < ApplicationController
  include ScopingHelpers

  before_action :set_context
  before_action :set_submission

  def show
    @submission_assets_tree = SubmissionStructureService.parse_submission(@submission)
    @submission_assets_tree = @submission_assets_tree.resolve(params[:path]) if params[:path].present?
  end

  private
  def set_context
    @exercise = Exercise.find params[:exercise_id]
    @term = @exercise.term
    @tutorial_group = current_tutorial_group(@term)
  end

  def set_submission
    @submission = @exercise.submissions.find(params[:submission_id])
    authorize @submission
  end
end
