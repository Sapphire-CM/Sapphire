class GradingScalesController < ApplicationController
  before_action :fetch_term, only: [:edit, :update]

  def edit
    @grading_scale = @term.grading_scale(@term.term_registrations.students)
  end

  def update
    p = params[:term][:grading_scale].first
    @term.update_grading_scale!(p.first, p.last)
    redirect_to edit_term_grading_scale_path, notice: "Successfully updated grading scale"
  end

  private

  def fetch_term
    @term = Term.find(params[:term_id])
    authorize GradingScalePolicy.with @term
  end
end
