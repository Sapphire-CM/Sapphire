class ReaddPointsToStudentGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :student_groups, :points, :integer
  end
end
