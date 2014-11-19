class AddVisiblePointsToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :visible_points, :integer
  end
end
