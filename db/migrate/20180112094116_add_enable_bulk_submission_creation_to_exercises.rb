class AddEnableBulkSubmissionCreationToExercises < ActiveRecord::Migration
  def change
    add_column :exercises, :enable_bulk_submission_creation, :boolean, default: false
  end
end
