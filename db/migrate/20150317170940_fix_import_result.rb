class FixImportResult < ActiveRecord::Migration[4.2]
  def change
    remove_column :import_results, :imported_student_registrations, :integer
  end
end
