class SubmissionEvaluations::CommentsController < CommentsController
  before_action :set_commentable, :set_term

  private
  
  def set_commentable
    @commentable = SubmissionEvaluation.find(params[:submission_evaluation_id])

    authorize @commentable
  end

  def set_term
    @term = @commentable.submission.term
  end
end
