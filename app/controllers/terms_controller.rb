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
      redirect_to course_term_path(@course, @term), :notice => "Term has been created"
    else
      render :new
    end
  end
    
  def edit
    @term = @course.terms.find(params[:id])
  end
  
  def update
    @term = @course.terms.find(params[:id])
    
    if @term.update_attributes(params[:term])
      redirect_to course_term_path(@course, @term), :notice => "Term has been updated"
    else
      render :edit
    end
  end

  def destroy
    @term = @course.terms.find(params[:id])
    @term.destroy
    redirect_to course_path(@course), :notice => "Term has been deleted"
  end
  
  private
  def fetch_course
    @course = Course.find(params[:course_id])
  end
  
  def current_term
    @term
  end
  helper_method :current_term
  
  def current_course
    @course
  end
  helper_method :current_course
end
