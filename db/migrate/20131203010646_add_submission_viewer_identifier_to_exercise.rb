class AddSubmissionViewerIdentifierToExercise < ActiveRecord::Migration[4.2]
  def change
    add_column :exercises, :submission_viewer_identifier, :string
  end
end
