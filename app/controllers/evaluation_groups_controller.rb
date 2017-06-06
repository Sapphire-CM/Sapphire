class EvaluationGroupsController < ApplicationController
  def update
    set_evaluation_group
    set_submission_evaluation
    set_submission

    update_evaluation_group
  end

  private

  def set_evaluation_group
    @evaluation_group = EvaluationGroup.find(params[:id])

    authorize(@evaluation_group)
  end

  def set_submission_evaluation
    @submission_evaluation = @evaluation_group.submission_evaluation
  end

  def set_submission
    @submission = @submission_evaluation.submission
  end

  def update_evaluation_group
    @evaluation_group.update(evaluation_group_params)
  end

  def evaluation_group_params
    params.require(:evaluation_group).permit(:status)
  end
end
