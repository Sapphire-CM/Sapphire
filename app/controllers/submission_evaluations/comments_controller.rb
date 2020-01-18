class SubmissionEvaluations::CommentsController < CommentsController
  before_action :set_commentable

  private
  
  def set_commentable
    @commentable = SubmissionEvaluation.find(params[:submission_evaluation_id])
  end
end
  
