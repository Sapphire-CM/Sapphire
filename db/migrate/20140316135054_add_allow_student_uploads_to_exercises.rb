class AddAllowStudentUploadsToExercises < ActiveRecord::Migration
  def change
    add_column :exercises, :allow_student_uploads, :boolean
  end
end
