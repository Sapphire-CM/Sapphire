class AddDescriptionToExercise < ActiveRecord::Migration[4.2]
  def change
    add_column :exercises, :description, :text
  end
end
