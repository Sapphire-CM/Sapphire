class AddProcessedSizeAndFilesystemSizeToSubmissionAssets < ActiveRecord::Migration[4.2]
  def change
    add_column :submission_assets, :processed_size, :integer, default: 0
    add_column :submission_assets, :filesystem_size, :integer, default: 0
  end
end
