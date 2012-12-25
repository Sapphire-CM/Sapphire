class TermsController < ApplicationController
  before_filter :fetch_course
  
  def show
    @term = @course.terms.find(params[:id])
    @tutorial_groups = @term.tutorial_groups
  end
  
  def new
    @term = @course.terms.new
  end
  
  
  def create
    @term = @course.terms.new(params[:term])
    
    if @term.save
      redirect_to [@course, @term], :notice => "Term has been created"
    else
      
    end
  end
  
  private
  def fetch_course
    @course = Course.find(params[:course_id])
  end
end
