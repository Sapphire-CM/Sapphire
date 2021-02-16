class AddSubmitterIdToSubmissionAsset < ActiveRecord::Migration
  def up
    add_reference :submission_assets, :submitter, index: true, null: true
    add_foreign_key :submission_assets, :accounts, column: :submitter_id

    Submission.find_each do |submission|
      if submission.submitter_id.present?
        submission.submission_assets.update_all(submitter_id: submission.submitter_id)
      elsif submission.exercise_registrations.first.present?
        submission.submission_assets.update_all(submitter_id: submission.exercise_registrations.first.term_registration.account)
      end
    end

    SubmissionAsset.where(submitter_id:nil).each do |sa|
      puts sa.id
    end

    change_column_null :submission_assets, :submitter_id, false
  end

  def down
    remove_reference :submission_assets, :submitter, foreign_key: true
    remove_foreign_key :submission_assets, :accounts
  end
end
