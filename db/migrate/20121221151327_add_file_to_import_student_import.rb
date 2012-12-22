class AddFileToImportStudentImport < ActiveRecord::Migration
  def change
    add_column :import_student_imports, :file, :string
  end
end
