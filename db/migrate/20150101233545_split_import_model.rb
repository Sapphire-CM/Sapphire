class SplitImportModel < ActiveRecord::Migration[4.2]
  def change
    create_table :import_options do |t|
      t.references :import

      t.integer :matching_groups
      t.string :tutorial_groups_regexp
      t.string :student_groups_regexp
      t.boolean :headers_on_first_line, default: true
      t.string :column_separator
      t.string :quote_char
      t.string :decimal_separator
      t.string :thousands_separator

      t.timestamps null: false
    end

    create_table :import_mappings do |t|
      t.references :import

      t.integer :group
      t.integer :email
      t.integer :forename
      t.integer :surname
      t.integer :matriculation_number
      t.integer :comment

      t.timestamps null: false
    end

    create_table :import_results do |t|
      t.references :import

      t.boolean :success, default: false
      t.boolean :encoding_error, default: false
      t.boolean :parsing_error, default: false
      t.integer :total_rows
      t.integer :processed_rows
      t.integer :imported_students
      t.integer :imported_tutorial_groups
      t.integer :imported_term_registrations
      t.integer :imported_student_groups
      t.integer :imported_student_registrations

      t.timestamps null: false
    end

    create_table :import_errors do |t|
      t.references :import_result

      t.string :row
      t.string :entry
      t.string :message

      t.timestamps null: false
    end
  end
end
