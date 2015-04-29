class GradingScalesController < ApplicationController
  before_action :fetch_term, only: [:edit, :update]

  def edit
    @grading_scale = GradingScaleService.new(@term, @term.term_registrations.students)
  end

  def update
    @term.update_grading_scale!(term_params[:grading_scale])
    redirect_to edit_term_grading_scale_path, notice: 'Successfully updated grading scale'
  end

  private

  def fetch_term
    @term = Term.find(params[:term_id])
    authorize GradingScalePolicy.with @term
  end

  def term_params
    params.require(:term).permit(grading_scale: [[]]).tap do |whitelisted|
      whitelisted[:grading_scale] = params[:term][:grading_scale].map do |scale|
        next unless scale.is_a?(Array) && scale.length == 2

        scale[0] = scale[0].to_s
        scale[1] = scale[1].to_i
        scale.reverse
      end.compact
    end
  end
end
