class AddPathToSubmissionAsset < ActiveRecord::Migration
  def change
    add_column :submission_assets, :path, :string, default: ''
  end
end
