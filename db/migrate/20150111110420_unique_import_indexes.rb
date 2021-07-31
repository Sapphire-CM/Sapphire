class UniqueImportIndexes < ActiveRecord::Migration[4.2]
  def change
    add_index :import_options, :import_id, unique: true
    add_index :import_mappings, :import_id, unique: true
    add_index :import_results, :import_id, unique: true
    add_index :import_errors, :import_result_id
  end
end
