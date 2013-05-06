class AddSubmissionTimeToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :submission_time, :time
  end
end
