class EvaluationsController < ApplicationController
  def update
    set_evaluation
    set_evaluation_group
    set_submission_evaluation
    set_submission
    set_rating

    if update_evaluation
      update_submission_evaluation
    else
      render :update_error
    end
  end

  def edit
    set_evaluation
    render 'comment'
  end

  private
  def set_evaluation
    @evaluation = Evaluation.find(params[:id])
    authorize @evaluation.becomes(Evaluation)
  end

  def set_evaluation_group
    @evaluation_group = @evaluation.evaluation_group
  end

  def set_submission_evaluation
    @submission_evaluation = @evaluation_group.submission_evaluation
  end

  def set_submission
    @submission = @submission_evaluation.submission
  end

  def set_rating
    @rating = @evaluation.rating
  end

  def update_evaluation
    @evaluation.update(evaluation_params)
  end

  def update_submission_evaluation
    @submission_evaluation.update(evaluated_at: Time.zone.now)
  end

  def evaluation_params
    params.require(:evaluation).permit(:value, :needs_review, :comment)
  end
end
