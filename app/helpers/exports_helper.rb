module ExportsHelper
  def export_options_for(export, form_builder)
    template = if lookup_context.template_exists?(export.class.to_s.underscore + '_options', ['exports'], true)
      export.class.to_s.underscore + '_options'
    else
      'export_options'
    end

    render template, f: form_builder, export: export
  end

  def download_link_title(export)
    file = export.file.to_s

    if File.exist? file
      size = File.size(file)
      foundation_icon(:download) + " download (#{number_to_human_size size})"
    else
      'file missing'
    end
  end
end
