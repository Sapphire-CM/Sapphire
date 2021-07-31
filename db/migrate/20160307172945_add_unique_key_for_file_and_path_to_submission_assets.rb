class AddUniqueKeyForFileAndPathToSubmissionAssets < ActiveRecord::Migration[4.2]
  def up
    ActiveRecord::Base.transaction do
      while (assets = SubmissionAsset.select("filename, path, submission_id").group(:filename, :path, :submission_id).having("count(*) > 1")).length > 0
        assets.each do |sa_attributes|
          submission_asset = SubmissionAsset.where(
            filename: sa_attributes.filename,
            path: sa_attributes.path,
            submission_id: sa_attributes.submission_id).first
          submission_asset.path = File.join(submission_asset.path, "__duplicates__")
          submission_asset.save(validate: false)
        end
      end

      add_index :submission_assets, [:filename, :path, :submission_id], :unique => true
    end
  end

  def down
    ActiveRecord::Base.transaction do
      remove_index :submission_assets, [:filename, :path, :submission_id]

      SubmissionAsset.where { path =~ "%__duplicates__%"}.each do |sa|
        sa.path = File.join(*sa.path.split("/").keep_if { |part| part != "__duplicates__" })
        sa.save(validate: false)
      end
    end
  end
end
