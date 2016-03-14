class SubmissionsController < ApplicationController
  before_action :set_submission, only: [:show, :edit]
  before_action :set_context, only: [:edit]

  def show
    redirect_to tree_submission_path(@submission)
  end

  def edit

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
