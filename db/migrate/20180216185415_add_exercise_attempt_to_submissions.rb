class AddExerciseAttemptToSubmissions < ActiveRecord::Migration
  def change
    add_reference :submissions, :exercise_attempt, index: true, foreign_key: true
  end
end
