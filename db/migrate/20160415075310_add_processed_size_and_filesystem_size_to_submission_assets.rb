class AddProcessedSizeAndFilesystemSizeToSubmissionAssets < ActiveRecord::Migration
  def change
    add_column :submission_assets, :processed_size, :integer
    add_column :submission_assets, :filesystem_size, :integer
  end
end
