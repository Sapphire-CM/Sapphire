class EvaluationsController < TermResourceController
  before_filter :fetch_exercise

  def index
    @students = current_term.students
    @rating_groups = @exercise.rating_groups
  end

  def create
    @evaluation = Evaluation.new(params[:evaluation])

    respond_to do |format|
      if @evaluation.save
        format.json { render json: @evaluation, status: :created, location: @evaluation }
      else
        format.json { render json: @evaluation.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @evaluation = Evaluation.find(params[:id])
    @evaluation.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
  def fetch_exercise
    @exercise = current_term.exercises.find(params[:exercise_id])
  end

end
