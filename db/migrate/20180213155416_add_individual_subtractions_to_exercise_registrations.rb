class AddIndividualSubtractionsToExerciseRegistrations < ActiveRecord::Migration
  def change
    add_column :exercise_registrations, :individual_subtractions, :integer
  end
end
