class AddStatusAndLineCountAndImportOptionsToImportStudentImports < ActiveRecord::Migration
  def change
    add_column :import_student_imports, :status, :string
    add_column :import_student_imports, :line_count, :integer
    add_column :import_student_imports, :import_options, :text
  end
end
