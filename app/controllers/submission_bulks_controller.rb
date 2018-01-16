class SubmissionBulksController < ApplicationController
  include ScopingHelpers
  before_action :set_context

  def show
    authorize SubmissionPolicy.term_policy_record(@term)

    @bulk = SubmissionBulk::Bulk.new(exercise: @exercise, account: current_account)
    @bulk.ensure_blank!
  end

  def update
    authorize SubmissionPolicy.term_policy_record(@term)

    @bulk = SubmissionBulk::Bulk.new({exercise: @exercise, account: current_account}.merge(submission_bulk_params))

    if @bulk.valid?
      @bulk.save

      redirect_to exercise_submissions_path(@exercise), notice: "Successfully completed bulk operation"
    else
      @bulk.ensure_blank!

      render :show
    end
  end

  private
  def set_context
    @exercise = Exercise.find params[:exercise_id]
    @term = @exercise.term
    @tutorial_group = current_tutorial_group(@term)
  end

  def submission_bulk_params
    params.require(:submission_bulk_bulk).permit(items_attributes: [:subject_id, evaluations_attributes: [:rating_id, :evaluation_id, :value]])
  end
end
