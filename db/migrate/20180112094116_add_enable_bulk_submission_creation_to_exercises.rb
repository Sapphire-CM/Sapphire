class AddEnableBulkSubmissionCreationToExercises < ActiveRecord::Migration[4.2]
  def change
    add_column :exercises, :enable_bulk_submission_creation, :boolean, default: false
  end
end
