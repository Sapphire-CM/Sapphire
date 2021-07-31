class AddAssetIdentifierToSubmissionAssets < ActiveRecord::Migration[4.2]
  def change
    add_column :submission_assets, :asset_identifier, :string
  end
end
