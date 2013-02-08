class AddDeadlinesToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :deadline, :datetime
    add_column :exercises, :late_deadline, :datetime
  end
end
