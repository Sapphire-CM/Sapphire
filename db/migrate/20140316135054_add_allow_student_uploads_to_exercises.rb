class AddAllowStudentUploadsToExercises < ActiveRecord::Migration[4.2]
  def change
    add_column :exercises, :allow_student_uploads, :boolean
  end
end
