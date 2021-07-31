class AddEnableMultipleAttemptsToExercises < ActiveRecord::Migration[4.2]
  def change
    add_column :exercises, :enable_multiple_attempts, :boolean, default: false, null: false
  end
end
