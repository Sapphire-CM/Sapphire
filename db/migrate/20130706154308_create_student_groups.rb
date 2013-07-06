class CreateStudentGroups < ActiveRecord::Migration
  def change
    create_table :student_group_registrations do |t|
      t.integer :exercise_id
      t.integer :student_group_id

      t.timestamps
    end

    create_table :student_groups do |t|
      t.string :name
      t.integer :tutorial_group_id

      t.timestamps
    end
  end
end
