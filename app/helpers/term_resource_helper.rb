module TermResourceHelper
  def term_context?
    if @term_context.nil?
      @term_context = (current_controller != StaticController && current_controller != CoursesController && current_controller != TermsController ) || (params[:controller] == "terms" && params[:action] == "show")
    end

    @term_context
  end

  def current_controller
    (params[:controller]+"_controller").camelize.constantize
  end
end
