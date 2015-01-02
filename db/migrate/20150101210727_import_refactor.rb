class ImportRefactor < ActiveRecord::Migration
  def up
    rename_table :import_student_imports, :imports
    remove_column :imports, :format
    remove_column :imports, :line_count

    add_column :imports, :new_status, :integer

    Import.all.each do |import|
      status = case import.status_before_type_cast
      when "pending" then "0"
      when "imported" then "1"
      when "failed" then "2"
      else "2"
      end

      import.update_column :new_status, status
    end

    remove_column :imports, :status
    rename_column :imports, :new_status, :status
  end

  def down
    rename_table :imports, :import_student_imports
    add_column :import_student_imports, :format, :string
    add_column :import_student_imports, :line_count, :integer
    change_column :import_student_imports, :status, :string
  end
end
