class AddSubmissionTimeToExercise < ActiveRecord::Migration[4.2]
  def change
    add_column :exercises, :submission_time, :time
  end
end
