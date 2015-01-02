module ImportsHelper
  def mapping_column_select(index)
    inverse_mapping = ImportMapping::IMPORTABLE.map { |a| [@import.import_mapping.send(a), a] }
    selected = inverse_mapping.to_h[index].to_s

    select_tag "mapping_column_#{index}",
      options_for_select([''] + ImportMapping::IMPORTABLE, selected),
      class: 'import_mapping',
      data: { index: index }
  end

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
