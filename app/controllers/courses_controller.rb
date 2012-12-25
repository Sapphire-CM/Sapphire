class CoursesController < ApplicationController
  def index
    @courses = Course.all
  end
  
  def show
    @course = Course.find(params[:id])
    @terms = @course.terms
  end
  
  def new
    @course = Course.new
  end
  
  def create
    @course = Course.new(params[:course])
    
    if @course.save
      redirect_to @course, :notice => "Course has been created"
    else
      render :new
    end
  end
end
