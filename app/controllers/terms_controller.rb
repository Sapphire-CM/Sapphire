class TermsController < ApplicationController
  def show
    @term = Term.find(params[:id])
    @course = @term.course
    @tutorial_groups = @term.tutorial_groups
  end
  
  def new
    @term = Term.new
    @term.course = Course.find(params[:course_id])
    @course = @term.course
  end
  
  def create
    @term = Term.new(params[:term])
    @course = @term.course
    
    if @term.save
      redirect_to @course, :notice => "Term has been created"
    else
      render :new
    end
  end
    
  def edit
    @term = Term.new(params[:term])
  end
  
  def update
    @term = Term.new(params[:term])
    @course = @term.course
    
    if @term.update_attributes(params[:course])
      redirect_to course_terms_path(@course), :notice => "Term has been updated"
    else
      render :edit
    end
  end

  def destroy
    @term = Term.find(params[:id])
    @course = @term.course
    @term.destroy
    redirect_to course_path(@course), :notice => "Term has been deleted"
  end
end
