class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.belongs_to :exercise
      t.belongs_to :student_registration
      t.datetime :submitted_at

      t.timestamps null: false
    end
    add_index :submissions, :exercise_id
    add_index :submissions, :student_registration_id
  end
end
