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
    headers = model.headers
    values = model.values.first(5)
    mapping = model.import_mapping
    column_count = model.column_count

    h.render 'imports/mapping_table',
      mapping: mapping,
      column_count: column_count,
      headers: headers,
      values: values,
      importable_attributes: (ImportMapping.columns.map(&:name) - ['id', 'import_id'])
  end
end
