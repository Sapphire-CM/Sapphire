class RenameEnableBulkSubmissionCreationToEnableBulkSubmissionManagementOfExercises < ActiveRecord::Migration[4.2]
  def change
    rename_column :exercises, :enable_bulk_submission_creation, :enable_bulk_submission_management
  end
end