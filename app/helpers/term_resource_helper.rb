module TermResourceHelper
  def term_context?
    if @in_term_context.nil?
      @in_term_context = current_controller.is_a? TermResourceController
    end
    
    @in_term_context
    false
  end
  
  def current_controller
    (params[:controller]+"_controller").camelize.constantize
  end
end
