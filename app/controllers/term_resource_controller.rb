class TermResourceController < ApplicationController
  before_filter :fetch_course_and_term
  
  private
  def fetch_course_and_term
    @course = Course.find(params[:course_id])
    @term = @course.terms.find(params[:term_id])
  end
end
