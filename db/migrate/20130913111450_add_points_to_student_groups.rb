class AddPointsToStudentGroups < ActiveRecord::Migration
  def change
    add_column :student_groups, :points, :integer
  end
end
