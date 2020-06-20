class ChangeSubmissionSubmitterNullFalse < ActiveRecord::Migration
  def change
    change_column_null :submissions, :submitter_id, false
  end
end
