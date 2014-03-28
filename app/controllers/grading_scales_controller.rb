class GradingScalesController < ApplicationController
  GradingScalePolicyRecord = Struct.new :term do
    def policy_class
      GradingScalePolicy
    end
  end

  before_action :fetch_term, only: [:edit, :update]

  def edit
    @grading_scale = @term.grading_scale
  end

  def update
    @term.update_grading_scale!(term_params[:grading_scale])
    redirect_to edit_term_grading_scale_path, notice: "Successfully updated grading scale"
  end

  private
  def fetch_term
    @term = Term.find(params[:term_id])
    authorize GradingScalePolicyRecord.new(@term)
  end

  def term_params
    params.require(:term).permit(grading_scale: [[]]).tap do |whitelisted|
      whitelisted[:grading_scale] = params[:term][:grading_scale].map do |scale|
        if scale.is_a?(Array) && scale.length == 2
          scale[0] = scale[0].to_s
          scale[1] = scale[1].to_i
          scale.reverse
        else
          nil
        end
      end.compact
    end
  end
end
