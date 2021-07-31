class AddInstructionsUrlToExercises < ActiveRecord::Migration[4.2]
  def change
    add_column :exercises, :instructions_url, :string
  end
end
