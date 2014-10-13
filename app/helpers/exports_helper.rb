module ExportsHelper
  def export_options_for(export, form_builder)
    template = if lookup_context.template_exists?(export.class.to_s.underscore + "_options", "exports", true)
      export.class.to_s.underscore + "_options"
    else
      "export_options"
    end

    render template, f: form_builder, export: export
  end
end
