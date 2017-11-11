class ExercisesController < ApplicationController
  include ExerciseContext

  before_action :set_context, only: [:edit, :update, :destroy]

  def index
    @term = Term.find(params[:term_id])

    authorize ExercisePolicy.term_policy_record(@term)

    @exercises = @term.exercises
  end

  def show
    @exercise = Exercise.find(params[:id])
    @term = @exercise.term
    authorize @exercise
  end

  def new
    @term = Term.find(params[:term_id])
    @exercise = Exercise.new
    @exercise.term = @term

    authorize @exercise
  end

  def create
    @exercise = Exercise.new(exercise_params)

    authorize @exercise

    @exercise.row_order_position = :last

    if @exercise.save
      redirect_to exercise_path(@exercise), notice: 'Exercise was successfully created.'
    else
      @term = @exercise.term
      render :new
    end
  end

  def edit
  end

  def update
    if @exercise.update(exercise_params)
      redirect_to edit_exercise_path(@exercise), notice:  'Exercise was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @exercise.destroy
    redirect_to term_exercises_path(@term), notice: 'Exercise was successfully deleted.'
  end

  private

  def set_context
    @exercise = Exercise.find(params[:id] || params[:exercise_id])
    authorize @exercise

    @term = @exercise.term
  end

  def exercise_params
    params.require(:exercise).permit(
      :term_id,
      :title,
      :description,
      :instructions_url,
      :deadline,
      :late_deadline,
      :group_submission,
      :points,
      :visible_points,
      :enable_min_required_points,
      :enable_max_total_points,
      :enable_student_uploads,
      :enable_max_upload_size,
      :max_total_points,
      :min_required_points,
      :submission_viewer_identifier,
      :maximum_upload_size)
  end
end
