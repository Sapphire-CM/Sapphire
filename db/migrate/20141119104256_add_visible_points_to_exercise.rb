class AddVisiblePointsToExercise < ActiveRecord::Migration[4.2]
  def change
    add_column :exercises, :visible_points, :integer
  end
end
