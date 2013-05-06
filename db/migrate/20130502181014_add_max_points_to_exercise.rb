class AddMaxPointsToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :max_points, :integer
  end
end
