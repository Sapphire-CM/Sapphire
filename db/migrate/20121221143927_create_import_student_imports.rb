class CreateImportStudentImports < ActiveRecord::Migration
  def change
    create_table :import_student_imports do |t|
      t.references :semester

      t.timestamps null: false
    end
    add_index :import_student_imports, :semester_id
  end
end
