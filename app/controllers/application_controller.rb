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
end
