class AddFlagToStudentGroup < ActiveRecord::Migration
  def change
    add_column :student_groups, :solitary, :boolean
  end
end
