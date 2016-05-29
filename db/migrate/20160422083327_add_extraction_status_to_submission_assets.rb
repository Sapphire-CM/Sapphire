class AddExtractionStatusToSubmissionAssets < ActiveRecord::Migration
  def change
    add_column :submission_assets, :extraction_status, :integer
  end
end
