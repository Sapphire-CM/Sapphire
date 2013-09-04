class ExercisesController < ApplicationController
  before_action :set_context, only: [:show, :edit, :update, :destroy]

  def show
  end

  def new
    @exercise = Exercise.new
    @term = Term.find(params[:term_id])
    @exercise.term = @term
  end

  def edit
  end

  def create
    @exercise = Exercise.new(params[:exercise])

    if @exercise.save
      redirect_to @exercise, notice: "Exercise was successfully created."
    else
      render :new
    end
  end

  def update
    if @exercise.update_attributes(params[:exercise])
      redirect_to @exercise, notice:  "Exercise was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @exercise.destroy
    redirect_to term_exercises_path(@term), notice: "Exercise was successfully deleted."
  end

  private
    def set_context
      @exercise = Exercise.find(params[:id] || params[:exercise_id])
      @term = @exercise.term
    end

end
