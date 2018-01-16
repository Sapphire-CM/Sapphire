class SubmissionBulks::SubjectsController < ApplicationController
  include ScopingHelpers
  before_action :set_context

  respond_to :json

  def index
    authorize SubmissionPolicy.term_policy_record(@term)

    finder = SubmissionBulk::SubjectsFinder.new(exercise: @exercise)
    @subjects = finder.search(params[:q]) if params[:q].present?
    sleep 0.5
  end

  private
  def set_context
    @exercise = Exercise.find params[:exercise_id]
    @term = @exercise.term
    @tutorial_group = current_tutorial_group(@term)
  end
end
