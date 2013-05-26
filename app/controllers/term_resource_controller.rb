class TermResourceController < ApplicationController

  private
  def current_course
    @current_course ||= Course.find(params[:course_id]) if params[:course_id]
  end
  helper_method :current_course

  def current_term
    id = params[:term_id] || params[:id]
    @current_term ||= current_course.terms.find(id) if id
  end
  helper_method :current_term
end
