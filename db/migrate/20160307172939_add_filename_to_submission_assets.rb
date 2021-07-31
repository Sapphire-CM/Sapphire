class AddFilenameToSubmissionAssets < ActiveRecord::Migration[4.2]
  def up
    add_column :submission_assets, :filename, :string

    SubmissionAsset.find_each do |sa|
      sa.filename = File.basename(sa.file.to_s)
      sa.save(validate: false)
    end
  end

  def down
    remove_column :submission_assets, :filename
  end
end
