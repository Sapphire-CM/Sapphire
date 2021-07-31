class AddExtractionStatusToSubmissionAssets < ActiveRecord::Migration[4.2]
  def change
    add_column :submission_assets, :extraction_status, :integer
  end
end
