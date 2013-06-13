class CoursesController < ApplicationController
  def index
    @courses = Course.includes(:terms).all
  end

  def show
    @course = Course.includes(:terms).find(params[:id])
    @terms = @course.terms
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(params[:course])

    if @course.save
      render partial: 'courses/insert_index_entry', locals: { course: @course }
    else
      render :new
    end
  end

  def edit
    @course = Course.find(params[:id])
  end

  def update
    @course = Course.find(params[:id])

    if @course.update_attributes(params[:course])
      render partial: 'courses/replace_index_entry', locals: { course: @course }
    else
      render :edit
    end
  end

  def destroy
    @course = Course.find(params[:id])
    @course.destroy

    render partial: 'courses/remove_index_entry', locals: { course: @course }
  end
end
