class ChangeImportStatusType < ActiveRecord::Migration
  def change
    Import::StudentImport.all.each do |student_import|
      status = case student_import.status_before_type_cast
      when "pending" then "0"
      when "imported" then "1"
      when "failed" then "2"
      else "2"
      end

      student_import.update_column :status, status
    end

    change_column :import_student_imports, :status, 'integer USING CAST(status AS integer)'
  end
end
