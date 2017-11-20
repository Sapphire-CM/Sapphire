class AddInstructionsUrlToExercises < ActiveRecord::Migration
  def change
    add_column :exercises, :instructions_url, :string
  end
end
