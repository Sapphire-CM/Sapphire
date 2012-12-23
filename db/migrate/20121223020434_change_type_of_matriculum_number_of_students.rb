class ChangeTypeOfMatriculumNumberOfStudents < ActiveRecord::Migration
  def up
    change_column :students, :matriculum_number, :string
    Student.all.each do |student|
      student.matriculum_number = student.matriculum_number.rjust(7,"0")
      student.save
    end
  end

  def down
    change_column :students, :matriculum_number, :integer
  end
end