module ExerciseContext
  extend ActiveSupport::Concern

  def current_exercise
    @exercise
  end

  private
  def fetch_exercise
    @exercise = current_term.exercises.find(params[:exercise_id])
  end

  included do
    include TermContext

    before_action :fetch_exercise
    helper_method :current_exercise
  end
end