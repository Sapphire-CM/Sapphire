class AddEnableMaxPointsToExercise < ActiveRecord::Migration[4.2]
  def change
    add_column :exercises, :enable_max_points, :boolean
  end
end
