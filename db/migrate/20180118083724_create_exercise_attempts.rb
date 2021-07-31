class CreateExerciseAttempts < ActiveRecord::Migration[4.2]
  def change
    create_table :exercise_attempts do |t|
      t.belongs_to :exercise, index: true, foreign_key: true
      t.string :title
      t.datetime :date
      t.timestamps null: false
    end
  end
end
