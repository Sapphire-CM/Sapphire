class AddActiveToStudentGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :student_groups, :active, :boolean, default: true
  end
end
