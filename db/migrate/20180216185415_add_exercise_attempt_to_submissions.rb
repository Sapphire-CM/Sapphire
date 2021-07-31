class AddExerciseAttemptToSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_reference :submissions, :exercise_attempt, index: true, foreign_key: true
  end
end
