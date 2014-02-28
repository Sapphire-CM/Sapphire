class ExercisesController < ApplicationController
  before_action :set_context, only: [:show, :edit, :update, :destroy]

  def show
  end

  def new
    @term = Term.find(params[:term_id])
    @exercise = @term.exercises.new
  end

  def edit
  end

  def create
    @exercise = Exercise.new(exercise_params)
    @exercise.row_order_position = :last

    if @exercise.save
      redirect_to @exercise, notice: "Exercise was successfully created."
    else
      render :new
    end
  end

  def update
    if @exercise.update(exercise_params)
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

    def exercise_params
      params.require(:exercise).permit(
        :term_id,
        :title,
        :description,
        :deadline,
        :late_deadline,
        :group_submission,
        :points,
        :enable_min_required_points,
        :enable_max_total_points,
        :max_total_points,
        :min_required_points,
        :submission_viewer_identifier)
    end

end
