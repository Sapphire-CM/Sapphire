class CreateStudentGroups < ActiveRecord::Migration
  def change
    create_table :student_group_registrations do |t|
      t.integer :exercise_id
      t.integer :student_group_id

      t.timestamps
    end
    add_index :student_group_registrations, [:exercise_id], :name => "index_student_group_registrations_on_exercise_id"
    add_index :student_group_registrations, [:student_group_id], :name => "index_student_group_registrations_on_student_group_id"

    create_table :student_groups do |t|
      t.string :name
      t.integer :tutorial_group_id

      t.timestamps
    end
    add_index :student_groups, ["tutorial_group_id"], :name => "index_student_groups_on_tutorial_group_id"


    remove_column :student_registrations, :tutorial_group_id
    add_column :student_registrations, :student_group_id, :integer
    add_index :student_registrations, [:student_group_id], :name => "index_student_registrations_on_student_group_id"

  end
end
