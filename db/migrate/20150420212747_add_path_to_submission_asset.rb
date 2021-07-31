class AddPathToSubmissionAsset < ActiveRecord::Migration[4.2]
  def change
    add_column :submission_assets, :path, :string, default: ''
  end
end
