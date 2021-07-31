class AddImportIdentifierToSubmissionAssets < ActiveRecord::Migration[4.2]
  def change
    add_column :submission_assets, :import_identifier, :string
  end
end
