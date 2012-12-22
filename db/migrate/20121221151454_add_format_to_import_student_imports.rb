class AddFormatToImportStudentImports < ActiveRecord::Migration
  def change
    add_column :import_student_imports, :format, :string
  end
end
