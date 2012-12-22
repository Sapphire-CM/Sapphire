class AddImportMappingToImportStudentImport < ActiveRecord::Migration
  def change
    add_column :import_student_imports, :import_mapping, :text
  end
end
