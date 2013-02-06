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
      redirect_to @course, :notice => "Term has been created"
    else
      render :new
    end
  end
    
  def edit
    @term = @course.term.find(params[:term])
  end
  
  def update
    @term = @course.terms.find(params[:term])
    
    if @term.update_attributes(params[:course])
      redirect_to course_terms_path(@course), :notice => "Term has been updated"
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
end
