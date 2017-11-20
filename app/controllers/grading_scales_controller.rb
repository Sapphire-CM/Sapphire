class GradingScalesController < ApplicationController
  include TermContext
  before_action :fetch_term, only: [:index, :update]

  def index
    authorize GradingScalePolicy.term_policy_record(@term)

    @grading_scales = @term.grading_scales.where(not_graded: false).ordered
    @grading_scale_service = GradingScaleService.new(@term)

    flash[:alert] = 'GradingScale is not valid' unless @term.valid_grading_scales?
  end

  def update
    @grading_scale = @term.grading_scales.find(params[:id])

    authorize @grading_scale

    if @grading_scale.update(grading_scale_params)
      redirect_to term_grading_scales_path, notice: 'Successfully updated grading scale'
    else
      redirect_to term_grading_scales_path, alert: 'Failed updating grading scale!'
    end
  end

  private

  def fetch_term
    @term = Term.find(params[:term_id])
  end

  def grading_scale_params
    params.require(:grading_scale).permit(:positive, :min_points, :max_points)
  end
end
