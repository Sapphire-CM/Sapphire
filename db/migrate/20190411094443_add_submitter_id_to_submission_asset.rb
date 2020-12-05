class AddSubmitterIdToSubmissionAsset < ActiveRecord::Migration
  def up
    add_reference :submission_assets, :submitter, index: true, foreign_key: { to_table: :accounts }, null: true

    Submission.find_each do |submission|
      if submission.submitter_id.present?
        submission.submission_assets.update_all(submitter_id: submission.submitter_id)
      elsif submission.exercise_registrations.first.present?
        submission.submission_assets.update_all(submitter_id: submission.exercise_registrations.first)
      end
    end

    change_column_null :submission_assets, :submitter_id, false
  end

  def down
    remove_reference :submission_assets, :submitter, foreign_key: true
  end
end
