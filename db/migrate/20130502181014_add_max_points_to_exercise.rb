class AddMaxPointsToExercise < ActiveRecord::Migration[4.2]
  def change
    add_column :exercises, :max_points, :integer
  end
end
