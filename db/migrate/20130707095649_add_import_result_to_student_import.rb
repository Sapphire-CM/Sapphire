class AddImportResultToStudentImport < ActiveRecord::Migration[4.2]
  def change
    add_column :import_student_imports, :import_result, :text
  end
end
