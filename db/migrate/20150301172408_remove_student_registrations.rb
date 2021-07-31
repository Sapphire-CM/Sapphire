class RemoveStudentRegistrations < ActiveRecord::Migration[4.2]
  def up
    drop_table :student_registrations
  end

  def down
    create_table :student_registrations do |t|
      t.belongs_to  :account
      t.belongs_to  :student_group
      t.string      :comment

      t.timestamps null: false
    end
  end
end
