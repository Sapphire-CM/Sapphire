class AddEnableMultipleAttemptsToExercises < ActiveRecord::Migration
  def change
    add_column :exercises, :enable_multiple_attempts, :boolean, default: false, null: false
  end
end
