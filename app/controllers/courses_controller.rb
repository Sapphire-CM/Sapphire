class CoursesController < ApplicationController
  before_action :set_course, only: [:edit, :update, :destroy]

  def index
    authorize Course
    @terms_by_course = policy_scope(Term.all).includes(:course).group_by(&:course)
    @courses = policy_scope(Course.all)
  end

  def new
    @course = Course.new
    authorize @course
  end

  def create
    @course = Course.new(course_params)
    authorize @course

    if @course.save
      respond_to do |format|
        format.html { redirect_to root_path, notice: "Course was successfully created" }
        format.js
      end
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @course.update(course_params)
      respond_to do |format|
        format.html { redirect_to root_path, notice: "Course was successfully updated" }
        format.js
      end
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
    authorize @course
  end

  def course_params
    params.require(:course).permit(
      :title,
      :description
    )
  end
end
