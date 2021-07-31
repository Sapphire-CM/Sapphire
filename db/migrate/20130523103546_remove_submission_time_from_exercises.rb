class RemoveSubmissionTimeFromExercises < ActiveRecord::Migration[4.2]
  def up
    remove_column :exercises, :submission_time
  end

  def down
    add_column :exercises, :submission_time, :time
  end
end
