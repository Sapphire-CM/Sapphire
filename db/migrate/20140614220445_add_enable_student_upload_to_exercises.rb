class AddEnableStudentUploadToExercises < ActiveRecord::Migration[4.2]
  def up
    add_column :exercises, :enable_student_uploads, :boolean, default: true
    Exercise.update_all(enable_student_uploads: true)
  end

  def down
    remove_column :exercises, :enable_student_uploads
  end
end
