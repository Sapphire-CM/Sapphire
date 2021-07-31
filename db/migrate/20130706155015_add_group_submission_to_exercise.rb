class AddGroupSubmissionToExercise < ActiveRecord::Migration[4.2]
  def change
    add_column :exercises, :group_submission, :boolean
  end
end
