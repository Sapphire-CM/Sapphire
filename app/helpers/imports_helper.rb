module ImportsHelper
  def import_progress_bar_status(import)
    unless import.running?
      if import.import_result.success?
        "success"
      else
        "alert"
      end
    end
  end

  def import_mapping_table(import)
    import_service = ImportService.new(import)

    render 'imports/mapping_table',
      headers: import_service.headers,
      values: import_service.values.first(5),
      column_count: import_service.column_count
  end
end
