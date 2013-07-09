class AddGroupSubmissionToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :group_submission, :boolean
  end
end
