class RenameOutdatedToActiveOfExerciseRegistrations < ActiveRecord::Migration
  class ExerciseRegistration < ActiveRecord::Base; end
  def change
    add_column :exercise_registrations, :active, :boolean, default: true, null: false

    say_with_time "Migrating data" do
      reversible do |dir|
        dir.up do
          ExerciseRegistration.where(outdated: true).update_all(active: false)
          ExerciseRegistration.where(outdated: false).update_all(active: true)
        end

        dir.down do
          ExerciseRegistration.where(active: true).update_all(outdated: false)
          ExerciseRegistration.where(active: false).update_all(outdated: true)
        end
      end
    end

    remove_column :exercise_registrations, :outdated, :boolean, default: true, null: false
  end
end
