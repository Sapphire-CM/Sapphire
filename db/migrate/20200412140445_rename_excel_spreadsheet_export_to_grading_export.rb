class RenameExcelSpreadsheetExportToGradingExport < ActiveRecord::Migration[4.2]
  class Export < ActiveRecord::Base; end

  PREVIOUS_TYPE = "Exports::ExcelSpreadsheetExport"
  NEW_TYPE = "Exports::GradingExport"

  def up
    Export.where(type: PREVIOUS_TYPE).update_all(type: NEW_TYPE)
  end

  def down
    Export.where(type: NEW_TYPE).update_all(type: PREVIOUS_TYPE)
  end
end
