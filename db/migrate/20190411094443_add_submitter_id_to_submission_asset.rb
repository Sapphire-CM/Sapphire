class AddSubmitterIdToSubmissionAsset < ActiveRecord::Migration
  def change
    add_reference :submission_assets, :submitter, index: true
  end
end
