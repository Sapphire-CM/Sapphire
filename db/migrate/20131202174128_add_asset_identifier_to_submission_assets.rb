class AddAssetIdentifierToSubmissionAssets < ActiveRecord::Migration
  def change
    add_column :submission_assets, :asset_identifier, :string
  end
end
