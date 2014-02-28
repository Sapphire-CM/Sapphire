class EvaluationsController < ApplicationController
  before_action :set_context

  def index
    @students = @term.students
    @rating_groups = @exercise.rating_groups
  end

  def create
    @evaluation = Evaluation.new(evaluation_params)

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
    def set_context
      @exercise = Exercise.find(params[:exercise_id])
      @term = @exercise.term
    end

    def evaluation_params
      params.require(:evaluation).permit(
        :type,
        :rating_id,
        :checked,
        :value,
        :evaluation_group_id,
        :checked_automatically)
    end
end
