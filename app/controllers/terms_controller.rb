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
      redirect_to @term, :notice => "Term has been created"
    else
      render :new
    end
  end
  
  private

end
