class AddFileToImportStudentImport < ActiveRecord::Migration[4.2]
  def change
    add_column :import_student_imports, :file, :string
  end
end
