class AddMinPointsForPositiveGradeToExercise < ActiveRecord::Migration[4.2]
  def change
    add_column :exercises, :enable_min_required_points, :boolean
    add_column :exercises, :min_required_points, :integer

    rename_column :exercises, :enable_max_points, :enable_max_total_points
    rename_column :exercises, :max_points, :max_total_points
  end
end
