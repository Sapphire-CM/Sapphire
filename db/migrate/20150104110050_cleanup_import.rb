class CleanupImport < ActiveRecord::Migration[4.2]
  def change
    remove_column :imports, :import_options
    remove_column :imports, :import_mapping
    remove_column :imports, :import_result
  end
end
