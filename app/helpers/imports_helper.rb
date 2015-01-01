module ImportsHelper
  def mapping_table_header(index, importable_attributes, mapping, form_builder)
    current_value = mapping[index]

    form_builder.input_field index.to_s,
      as: :select,
      collection: importable_attributes,
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
