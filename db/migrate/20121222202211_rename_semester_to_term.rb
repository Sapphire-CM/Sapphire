class RenameSemesterToTerm < ActiveRecord::Migration
  def change
    rename_table :semesters, :terms
    rename_column :import_student_imports, :semester_id, :term_id
    rename_index :terms, "index_semesters_on_course_id", "index_terms_on_course_id"
  end
end