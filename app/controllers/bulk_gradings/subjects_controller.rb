class BulkGradings::SubjectsController < ApplicationController
  include ScopingHelpers
  before_action :set_context

  respond_to :json

  def index
    authorize BulkGradings::SubjectPolicy.policy_record_with(exercise: @exercise)

    finder = BulkGradings::SubjectsFinder.new(exercise: @exercise)
    @subjects = finder.search(params[:q]) if params[:q].present?
  end

  private
  def set_context
    @exercise = Exercise.find params[:exercise_id]
    @term = @exercise.term
    @tutorial_group = current_tutorial_group(@term)
  end
end
