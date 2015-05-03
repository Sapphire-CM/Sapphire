class GradingScalesController < ApplicationController
  include TermContext
  before_action :fetch_term, only: [:index, :update]

  def index
    @grading_scales = @term.grading_scales.where(not_graded: false).ordered
    # @grading_scale_service = GradingScaleService.new(@term, @term.term_registrations.students)
  end

  def update
    @grading_scale = @term.grading_scales.find(params[:id])
    if @grading_scale.update(term_params)
      redirect_to term_grading_scales_path, notice: 'Successfully updated grading scale'
    else
      render :index, alert: 'Failed updating grading scale!'
    end
  end

  private

  def fetch_term
    @term = Term.find(params[:term_id])
    authorize GradingScalePolicy.with @term
  end

  def grading_scale_params
    params.require(:grading_scale).permit(:positive, :min_points, :max_points)
  end
end
