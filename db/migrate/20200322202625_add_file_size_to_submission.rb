class AddFileSizeToSubmission < ActiveRecord::Migration
  def up
    add_column :submissions, :filesystem_size, :integer, default: 0
    SubmissionAsset.find_each do |submission_asset|
      submission_asset.add_to_submission_filesize unless submission_asset.filesystem_size.nil?
    end
  end

  def down
    remove_column :submissions, :filesystem_size, :integer, default: 0
  end
end
