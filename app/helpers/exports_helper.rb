module ExportsHelper
  def export_options_for(export, form_builder)
    path = export.class.to_s.underscore.sub('exports/', '') + '_options'

    template = if lookup_context.template_exists?(path, ['exports'], true)
      path
    else
      'export_options'
    end

    render template, f: form_builder, export: export
  end

  def download_link_title(export)
    raise "Add number_to_human_size call back to show human readable file size" if Gem.loaded_specs["rails"].version >= Gem::Version.new('5.1.0')
    
    file = export.file.to_s

    if File.exist? file
      size = File.size(file)
      foundation_icon(:download)# + " download (#{number_to_human_size size})"
    else
      'file missing'
    end
  end
end
