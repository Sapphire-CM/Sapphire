module ApplicationHelper
  def term_context?
    if @term_context.nil?
      @term_context = (
        current_controller != AccountsController &&
        current_controller != CoursesController &&
        current_controller != TermsController
        ) ||
      (params[:controller] == "terms" && params[:action] == "show") || (params[:term_id])
    end

    @term_context
  end

  def current_controller
    (params[:controller]+"_controller").camelize.constantize
  end

  def coderay(code, lang = :ruby)
    CodeRay.scan(code, lang).div.html_safe
  end
end
