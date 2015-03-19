class FixImportResult < ActiveRecord::Migration
  def change
    remove_column :import_results, :imported_student_registrations, :integer
  end
end
