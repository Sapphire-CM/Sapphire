module ExportsHelper
  def export_options_for(export, form_builder)
    template = if lookup_context.template_exists?(export.class.to_s.underscore + '_options', 'exports', true)
      export.class.to_s.underscore + '_options'
    else
      'export_options'
    end

    render template, f: form_builder, export: export
  end

  def download_link_title(export)
    foundation_icon(:download) + " download (#{number_to_human_size File.size(export.file.to_s)})"
  end
end
