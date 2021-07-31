class CreateExerciseRegistrations < ActiveRecord::Migration[4.2]
  def change
    create_table :exercise_registrations do |t|
      t.belongs_to :exercise, index: true
      t.belongs_to :term_registration, index: true
      t.belongs_to :submission, index: true
      t.integer :points
      t.timestamps null: false
    end
  end
end
