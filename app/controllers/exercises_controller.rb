class ExercisesController < TermResourceController

  def show
    @exercise = current_term.exercises.find(params[:id])
  end

  def new
    @exercise = current_term.exercises.new
  end

  def edit
    @exercise = current_term.exercises.find(params[:id])
  end

  def create
    @exercise = current_term.exercises.new(params[:exercise])

    if @exercise.save
      redirect_to course_term_exercise_path(current_course, current_term, @exercise), notice: "Exercise was successfully created."
    else
      render :new
    end
  end

  def update
    @exercise = current_term.exercises.find(params[:id])

    if @exercise.update_attributes(params[:exercise])
      redirect_to course_term_exercise_path(current_course, current_term, @exercise), notice:  "Exercise was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @exercise = current_term.exercises.find(params[:id])
    @exercise.destroy

    redirect_to course_term_exercises_path(current_course, current_term), notice: "Exercise was successfully deleted."
  end
end
