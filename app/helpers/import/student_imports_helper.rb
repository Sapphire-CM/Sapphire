module Import::StudentImportsHelper
  def mapping_table_header(index, importable_attributes, mapping, form_builder)
    current_value = mapping[index]
    
    form_builder.input_field(index.to_s, :as => :select, :collection => importable_attributes, :selected => current_value, :include_blank => true)
  end
end
