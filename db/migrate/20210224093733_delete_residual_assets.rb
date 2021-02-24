class DeleteResidualAssets < ActiveRecord::Migration
  def change
    SubmissionAsset.where.not(submission_id: Submission.select(:id)).each do |sa|
      sa.destroy
    end
  end
end
