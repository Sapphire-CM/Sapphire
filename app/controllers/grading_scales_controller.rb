class GradingScalesController < ApplicationController
  include TermContext
  before_action :fetch_term, only: [:index, :bulk_update]

  def index
    authorize GradingScalePolicy.term_policy_record(@term)

    @grading_scales = @term.grading_scales.where(not_graded: false).ordered
    @grading_scale_service = GradingScaleService.new(@term)

    flash[:alert] = 'GradingScale is not valid' unless @term.valid_grading_scales?
  end

  def bulk_update
    authorize GradingScalePolicy.term_policy_record(@term)

    @grading_scale_bulk = GradingScale::Bulk.new(grading_scale_params)
    @grading_scale_bulk.term = @term

    if @grading_scale_bulk.save
      flash[:notice] = "Successfully updated grading scale"
      respond_to do |format|
        format.html { redirect_to term_grading_scales_path(@term) }
        format.json { head :ok }
      end
    else
      flash[:alert] = "Failed updating grading scale!"
      respond_to do |format|
        format.html { redirect_to term_grading_scales_path(@term) }
        format.json { head :bad_request }
      end
    end
  end

  private

  def fetch_term
    @term = Term.find(params[:term_id])
  end

  def grading_scale_params
    params.require(:grading_scales).permit(grading_scale_attributes: [:id, :min_points, :max_points])
  end
end
