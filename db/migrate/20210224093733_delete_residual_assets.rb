class DeleteResidualAssets < ActiveRecord::Migration[4.2]
  def change
    SubmissionAsset.where.not(submission_id: Submission.select(:id)).each do |sa|
      sa.destroy
    end
  end
end
