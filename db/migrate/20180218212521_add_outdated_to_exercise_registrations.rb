class AddOutdatedToExerciseRegistrations < ActiveRecord::Migration[4.2]
  class ExerciseRegistration < ActiveRecord::Base
    belongs_to :submission
  end

  class Submission < ActiveRecord::Base
    has_many :exercise_registrations
  end

  def change
    add_column :exercise_registrations, :outdated, :boolean, default: false, null: false

    reversible do |dir|
      dir.up do
        say_with_time "Setting exercise registrations of outdated submissions to outdated" do
          ExerciseRegistration.joins(:submission).where(submission: { outdated: true } ).update_all(outdated: true)
        end

        say_with_time "Setting exercise registrations of recent submissions to recent" do
          ExerciseRegistration.joins(:submission).where(submission: { outdated: false } ).update_all(outdated: false)
        end
      end
    end
  end
end
