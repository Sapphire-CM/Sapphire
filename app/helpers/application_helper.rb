module ApplicationHelper
  def term_context?
    if @term_context.nil?
      @term_context = (
        current_controller != AccountsController &&
        current_controller != EmailAddressesController &&
        current_controller != CoursesController &&
        current_controller != TermsController &&
        current_controller != SystemDiskStatisticsController
      ) ||
      (params[:controller] == 'terms' && !%w(index new create).include?(params[:action])) || (params[:term_id])
    end

    @term_context
  end

  def iso_time(time)
    l(time, format: :unix)
  end

  def current_controller
    @current_controller ||= (params[:controller] + '_controller').camelize.constantize
  end

  def coderay(code, lang = :ruby)
    CodeRay.scan(code, lang).div.html_safe
  end

  def ajax_load(url)
    id = Time.now.to_i.to_s

    indicator = content_tag :div, id: 'ajax-load-indicator', class: 'grid-center' do
      image_tag 'ajax-loader.svg'
    end

    content_tag :div, id: id do
      javascript_tag "ajax_load('#{id}', '#{url}', '#{indicator}');"
    end
  end
end
