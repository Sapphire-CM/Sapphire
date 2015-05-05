module ExerciseContext
  extend ActiveSupport::Concern

  included do
    include TermContext

    before_action :fetch_exercise
    helper_method :current_exercise
  end

  def current_exercise
    @exercise
  end

  private

  def fetch_exercise
    id = params[:exercise_id]
    @exercise = current_term.exercises.find_by_id(id) if id
  end
end
