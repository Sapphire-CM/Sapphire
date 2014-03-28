class AddActiveToStudentGroup < ActiveRecord::Migration
  def change
    add_column :student_groups, :active, :boolean, default: true
  end
end
