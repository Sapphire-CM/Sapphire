class Evaluations::CommentsController < CommentsController
  before_action :set_commentable, :set_term

  def show
    @commentable.becomes(Evaluation)

    render "comments/show"
  end

  private
  
  def set_commentable
    @commentable = Evaluation.find(params[:evaluation_id])

    authorize @commentable.becomes(Evaluation)
  end

  def set_term
    @term = @commentable.submission.term
  end
end
  
