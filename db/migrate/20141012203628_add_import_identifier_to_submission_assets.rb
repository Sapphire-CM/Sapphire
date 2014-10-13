class AddImportIdentifierToSubmissionAssets < ActiveRecord::Migration
  def change
    add_column :submission_assets, :import_identifier, :string
  end
end
