class ChangeSubmissionSubmitterNullFalse < ActiveRecord::Migration[4.2]
  def change
    change_column_null :submissions, :submitter_id, false
  end
end
