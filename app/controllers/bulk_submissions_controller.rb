class BulkSubmissionsController < ApplicationController
  before_action :set_context

  def index

  end

  private
  def set_context
    @exercise = Exercise.find params[:exercise_id]
    @term = @exercise.term
    @tutorial_group = current_tutorial_group(@term)
  end
end
