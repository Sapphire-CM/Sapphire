class RemoveSubmissionTimeFromExercises < ActiveRecord::Migration
  def up
    remove_column :exercises, :submission_time
  end

  def down
    add_column :exercises, :submission_time, :time
  end
end
