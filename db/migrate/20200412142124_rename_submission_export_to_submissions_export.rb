class RenameSubmissionExportToSubmissionsExport < ActiveRecord::Migration[4.2]
  class Export < ActiveRecord::Base; end

  PREVIOUS_TYPE = "Exports::SubmissionExport"
  NEW_TYPE = "Exports::SubmissionsExport"

  def up
    Export.where(type: PREVIOUS_TYPE).update_all(type: NEW_TYPE)
  end

  def down
    Export.where(type: NEW_TYPE).update_all(type: PREVIOUS_TYPE)
  end
end
