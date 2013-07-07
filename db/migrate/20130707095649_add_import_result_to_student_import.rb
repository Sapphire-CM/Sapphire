class AddImportResultToStudentImport < ActiveRecord::Migration
  def change
    add_column :import_student_imports, :import_result, :text
  end
end
