class RenameSemesterToTerm < ActiveRecord::Migration
  def change
    rename_index :semesters, "index_semesters_on_course_id", "index_terms_on_course_id"
    rename_table :semesters, :terms
    rename_column :import_student_imports, :semester_id, :term_id
  end
end
