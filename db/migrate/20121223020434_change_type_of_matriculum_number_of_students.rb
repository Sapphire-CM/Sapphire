class ChangeTypeOfMatriculumNumberOfStudents < ActiveRecord::Migration[4.2]
  def up
    change_column :students, :matriculum_number, :string
  end

  def down
    change_column :students, :matriculum_number, :integer
  end
end