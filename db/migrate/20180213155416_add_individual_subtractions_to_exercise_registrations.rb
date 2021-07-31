class AddIndividualSubtractionsToExerciseRegistrations < ActiveRecord::Migration[4.2]
  def change
    add_column :exercise_registrations, :individual_subtractions, :integer
  end
end
