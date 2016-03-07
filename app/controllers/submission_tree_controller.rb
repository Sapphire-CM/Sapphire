class SubmissionTreeController < ApplicationController
  include ScopingHelpers

  before_action :set_submission
  before_action :set_context

  def show
    @tree = @submission.tree(params[:path])
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
