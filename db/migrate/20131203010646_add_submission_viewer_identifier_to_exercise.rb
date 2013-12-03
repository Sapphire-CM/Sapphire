class AddSubmissionViewerIdentifierToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :submission_viewer_identifier, :string
  end
end
