class TermResourceController < ApplicationController

  private
  def current_course
    @current_course ||= Course.find(params[:course_id])
  end
  helper_method :current_course


  def current_term
    @current_term ||= current_course.terms.find(params[:term_id])
  end
  helper_method :current_term
end
