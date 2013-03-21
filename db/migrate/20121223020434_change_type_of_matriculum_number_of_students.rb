class ChangeTypeOfMatriculumNumberOfStudents < ActiveRecord::Migration
  def up
    change_column :students, :matriculum_number, :string
  end

  def down
    change_column :students, :matriculum_number, :integer
  end
end