class SubmissionEvaluationsController < ApplicationController
  before_action :set_submission_evaluation, only: [:show, :new, :create, :edit, :update, :destroy]

  def show
    unless @submission_evaluation.present?
      redirect_to new_submission_evaluation_path(current_submission)
      return
    end
  end

  def new
    if @submission_evaluation.present?
      redirect_to edit_submission_evaluation_path(current_submission)
      return
    end

    @submission_evaluation = SubmissionEvaluation.new
    @submission_evaluation.submission = current_submission
  end

  def create
    if @submission_evaluation.present?
      redirect_to submission_evaluation_path(current_submission), alert: "Error - Evaluation already present"
      return
    end

    @submission_evaluation = SubmissionEvaluation.new(submission_evaluation_params)
    @submission_evaluation.submission = current_submission
    @submission_evaluation.evaluator = current_account
    @submission_evaluation.evaluated_at = Time.now

    if @submission_evaluation.save
      @submission_evaluation.update_evaluation_result!
      redirect_to submission_evaluation_path(current_submission), notice: "Evaluation has been created"
    else
      render :new
    end
  end

  def edit
    unless @submission_evaluation.present?
      redirect_to new_submission_evaluation_path(current_submission)
      return
    end
  end

  def update
    unless @submission_evaluation.present?
      redirect_to new_submission_evaluation_path(current_submission)
      return
    end

    @submission_evaluation.evaluator = current_account unless @submission_evaluation.evaluator.present?

    if @submission_evaluation.update_attributes(submission_evaluation_params)
      @submission_evaluation.update_evaluation_result!
      redirect_to submission_evaluation_path(current_submission), notice: "Evaluation has been updated"
    else
      render :edit
    end
  end

  private
    def submission_evaluation_params
      params.require(:submission_evaluation).permit(
        :submission_id,
        :evaluator_id,
        :evaluator_type,
        :evaluated_at,
        :evaluation_result,
        :plagiarized)
    end

    def set_submission_evaluation
      @submission_evaluation = current_submission.submission_evaluation
    end

    def prepared_evaluations
      @evaluations ||= @submission_evaluation.prepared_evaluations.group_by {|ev| ev.rating_group}
    end
    helper_method :prepared_evaluations

    def current_submission
      @submission ||= current_term.submissions.find(params[:submission_id])
    end
    helper_method :current_submission

end
