class AddDescriptionToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :description, :text
  end
end
