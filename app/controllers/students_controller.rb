class StudentsController < ApplicationController  
  def index
    @students = Student.scoped.page(params[:page]).per(100)
    
    @students = @students.search(params[:q]) if params[:q].present?
  end
  
  def show
    @student = StudentDecorator.decorate Student.find(params[:id])
    @term_registrations = @student.term_registrations
    
    @grouped_term_registrations = @term_registrations.group_by(&:course)
  end
  
  def new
    @student = Student.new

  end
  
  def create
    @student = Student.new(params[:student])
    if @student.save
      redirect_to @student, :notice => "Student successfully created"
    else
      render :new
    end
  end
  
  def edit
    @student = Student.find(params[:id])
  end
  
  def destroy
    @student = Student.find(params[:id])
    
    @student.destroy
    redirect_to students_path
  end
end
