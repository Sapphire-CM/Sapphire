class AddPointsToExercise < ActiveRecord::Migration[4.2]
  def change
    add_column :exercises, :points, :integer
  end
end
