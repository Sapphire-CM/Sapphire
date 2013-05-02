class AddEnableMaxPointsToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :enable_max_points, :boolean
  end
end
