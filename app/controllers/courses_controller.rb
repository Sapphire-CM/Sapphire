class CoursesController < ApplicationController
  before_action :set_course, only: [:edit, :update, :destroy]

  def index
    @courses = Course.includes(:terms).load
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)

    if @course.save
      render partial: 'courses/insert_index_entry', locals: { course: @course }
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @course.update(course_params)
      render partial: 'courses/replace_index_entry', locals: { course: @course }
    else
      render :edit
    end
  end

  def destroy
    @course.destroy
    render partial: 'courses/remove_index_entry', locals: { course: @course }
  end

  private
    def set_course
      @course = Course.find(params[:id])
    end

    def course_params
      params.require(:course).permit(
        :title,
        :discription)
    end
end
