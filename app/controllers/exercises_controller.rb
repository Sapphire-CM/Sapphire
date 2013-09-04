class ExercisesController < TermResourceController
  before_action :set_exercise, only: [:show, :edit, :update, :destroy]

  def show
  end

  def new
    @exercise = Exercise.new
    @exercise.term = Term.find(params[:term_id])
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
    redirect_to term_exercises_path(current_term), notice: "Exercise was successfully deleted."
  end

  private
    def set_exercise
      @exercise = Exercise.find(params[:id])
      @term = @exercise.term
    end

end
