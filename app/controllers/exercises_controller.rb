class ExercisesController < ApplicationController
  before_action :set_context, only: [:edit, :update, :destroy]

  skip_after_action :verify_authorized, only: :index

  def index
    @term = Term.find(params[:term_id])
    @exercises = @term.exercises

    raise Pundit::NotAuthorizedError unless ExercisePolicy.new(pundit_user, @term).index?
  end


  def new
    @term = Term.find(params[:term_id])
    @exercise = @term.exercises.new
    authorize @exercise
  end

  def create
    @exercise = Exercise.new(exercise_params)
    authorize @exercise
    @exercise.row_order_position = :last
    @term = @exercise.term

    if @exercise.save
      redirect_to term_exercises_path(@term), notice: "Exercise was successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @exercise.update(exercise_params)
      redirect_to edit_exercise_path(@exercise), notice:  "Exercise was successfully updated."
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
      authorize @exercise
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
        :enable_student_uploads,
        :max_total_points,
        :min_required_points,
        :submission_viewer_identifier,
        :maximum_upload_size)
    end

end
