class CourseBaseController < ApplicationController
  before_filter :fetch_course_or_redirect
  
  private
  
  def fetch_course_or_redirect
    @course = current_course
    
    unless @course
      redirect_to root_path, :notice => "Please select a course"
      false
    end
  end
end
