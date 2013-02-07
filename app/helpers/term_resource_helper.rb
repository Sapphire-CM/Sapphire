module TermResourceHelper
  def term_context?
    if @term_context.nil?
      @term_context = current_controller < TermResourceController || (params[:controller] == "terms" && params[:action] == "show")
    end
    
    @term_context
  end
  
  def current_controller
    (params[:controller]+"_controller").camelize.constantize
  end
end
