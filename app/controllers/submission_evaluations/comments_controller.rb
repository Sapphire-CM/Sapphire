class SubmissionEvaluations::CommentsController < CommentsController
  before_action :set_commentable, :set_term

  def show
    authorize Comment
    puts("rendering comment show")
    render "comment/show"
  end

  private
  
  def set_commentable
    @commentable = SubmissionEvaluation.find(params[:submission_evaluation_id])
  end

  def set_term
    @term = @commentable.submission.term
  end
end
  
