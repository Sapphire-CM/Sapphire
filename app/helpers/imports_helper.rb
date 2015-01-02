module ImportsHelper
  def mapping_table_header(index, import_mapping, form_builder)
    current_value = import_mapping.swapped[index]

    form_builder.input_field index.to_s,
      as: :select,
      collection: ImportMapping::IMPORTABLE,
      selected: current_value,
      include_blank: true,
      class: 'import-mapping'
  end

  def import_progress_bar_status(import)
    unless import.running?
      if import.import_result[:success]
        "success"
      else
        "alert"
      end
    end
  end
end
