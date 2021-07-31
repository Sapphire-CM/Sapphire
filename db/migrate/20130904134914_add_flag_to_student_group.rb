class AddFlagToStudentGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :student_groups, :solitary, :boolean
  end
end
