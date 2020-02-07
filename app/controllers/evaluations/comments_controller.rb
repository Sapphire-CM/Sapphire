class Evaluations::CommentsController < CommentsController
  before_action :set_commentable, :set_term

  def show
    render "comment/show"
  end

  private
  
  def set_commentable
    @commentable = Evaluation.find(params[:evaluation_id])

    authorize @commentable
  end

  def set_term
    @term = @commentable.submission.term
  end
end
  
