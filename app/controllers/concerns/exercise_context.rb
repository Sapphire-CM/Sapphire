module ExerciseContext
  extend ActiveSupport::Concern

  included do
    include TermContext

    before_action :fetch_exercise
    helper_method :current_exercise
  end

  private

  def current_exercise
    @exercise
  end

  def fetch_exercise
    @exercise = current_term.exercises.find(params[:exercise_id])
  end
end
