module ServicesHelper
  def service_options_for(service, form_builder)
    template = if lookup_context.template_exists?(service.class.to_s.underscore + '_options', 'services', true)
      service.class.to_s.underscore + '_options'
    else
      'service_options'
    end

    render template, f: form_builder, service: service
  end
end
