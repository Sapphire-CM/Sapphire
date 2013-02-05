class ApplicationController < ActionController::Base
  protect_from_forgery
  
  protected
  def current_context
    @current_context ||= Context.new(session[:context] || {})
  end
  helper_method :current_context
  
  def current_course
    current_context.current_course
  end
  helper_method :current_course
  
  def current_term
    current_context.current_term
  end
  helper_method :current_term
  
  def term_context?
    !current_term.nil?
  end
  helper_method :term_context?
  
  # used as before_filter
  def term_context_needed!
    redirect_to context_index_path, :notice => "Please choose a term in order to proceed" unless term_context?
  end

end
