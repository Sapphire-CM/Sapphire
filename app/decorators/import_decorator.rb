class ImportDecorator < Draper::Decorator
  delegate_all

  def term_title
    model.term.title
  end

  def filename
    File.basename model.file.to_s
  end

  def created_at
    h.localize model.created_at, format: :long
  end

  def students_count
    if model.finished?
      200 # TODO ?!?
    else
      h.content_tag :span, "?", class: "grey"
    end
  end

  def mapping_table
    import_service = ImportService.new(model)

    h.render 'imports/mapping_table',
      mapping: model.import_mapping,
      headers: import_service.headers,
      values: import_service.values.first(5),
      column_count: import_service.column_count,
      importable_attributes: (ImportMapping.columns.map(&:name) - ['id', 'import_id'])
  end
end
