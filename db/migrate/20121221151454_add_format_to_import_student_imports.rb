class AddFormatToImportStudentImports < ActiveRecord::Migration[4.2]
  def change
    add_column :import_student_imports, :format, :string
  end
end
