class ImportDecorator < Draper::Decorator
  delegate_all

  def mapping_table
    import_service = ImportService.new(model)

    h.render 'imports/mapping_table',
      headers: import_service.headers,
      values: import_service.values.first(5),
      column_count: import_service.column_count
  end
end
