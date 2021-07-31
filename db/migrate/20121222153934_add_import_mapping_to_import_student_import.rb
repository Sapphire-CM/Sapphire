class AddImportMappingToImportStudentImport < ActiveRecord::Migration[4.2]
  def change
    add_column :import_student_imports, :import_mapping, :text
  end
end
