class ApplicationController < ActionController::Base
  protect_from_forgery
  
  
  protected
  def current_course
    # todo: fill out this course dynamically
    @current_course ||= Course.find(1)
  end
  helper_method :current_course
  
  def current_term
    @@current_term ||= current_course.active_term
  end
  helper_method :current_term
end
