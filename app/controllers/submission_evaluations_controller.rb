class SubmissionEvaluationsController < ApplicationController
  def show
    @submission_evaluation = current_submission.submission_evaluation

    redirect_to new_submission_evaluation_path(current_submission) unless @submission_evaluation.present?
  end

  def new
    @submission_evaluation = current_submission.submission_evaluation

    if @submission_evaluation.present?
      redirect_to edit_submission_evaluation_path(current_submission)
      return
    end

    @submission_evaluation = SubmissionEvaluation.new
    @submission_evaluation.submission = current_submission
  end

  def create
    @submission_evaluation = current_submission.submission_evaluation
    if @submission_evaluation.present?
      redirect_to submission_evaluation_path(current_submission), :alert => "Error - Evaluation already present"
      return
    end

    @submission_evaluation = SubmissionEvaluation.new(params[:submission_evaluation])
    @submission_evaluation.submission = current_submission
    @submission_evaluation.evaluator = current_account
    @submission_evaluation.evaluated_at = Time.now

    if @submission_evaluation.save
      @submission_evaluation.update_evaluation_result!
      redirect_to submission_evaluation_path(current_submission), :notice => "Evaluation has been created"
    else
      render :new
    end
  end

  def edit
    @submission_evaluation = current_submission.submission_evaluation

    redirect_to new_submission_evaluation_path(current_submission) unless @submission_evaluation.present?
  end

  def update
    @submission_evaluation = current_submission.submission_evaluation
    unless @submission_evaluation.present?
      redirect_to new_submission_evaluation_path(current_submission)
      return
    end

    @submission_evaluation.evaluator = current_account unless @submission_evaluation.evaluator.present?

    if @submission_evaluation.update_attributes(params[:submission_evaluation])
      @submission_evaluation.update_evaluation_result!
      redirect_to submission_evaluation_path(current_submission), :notice => "Evaluation has been updated"
    else

      render :edit
    end
  end

  private
    def prepared_evaluations
      @evaluations ||= @submission_evaluation.prepared_evaluations.group_by {|ev| ev.rating_group}
    end
    helper_method :prepared_evaluations

    def current_submission
      @submission ||= current_term.submissions.find(params[:submission_id])
    end
    helper_method :current_submission

end
