class StudentsController < ApplicationController
  def index
    @students = Student.scoped.page(params[:page]).per(100)
    
    @students = @students.search(params[:q]) if params[:q].present?
  end
end
