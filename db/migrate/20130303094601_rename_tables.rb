class RenameTables < ActiveRecord::Migration[4.2]
  def up
    rename_table :lecturer_term_registrations, :lecturer_registrations
    rename_table :tutor_term_registrations, :tutor_registrations
    rename_table :student_term_registrations, :student_registrations
  end

  def down
    rename_table :lecturer_registrations, :lecturer_term_registrations
    rename_table :tutor_registrations, :tutor_term_registrations
    rename_table :student_registrations, :student_term_registrations
  end
end
