class Evaluations::ExplanationsController < CommentsController
  before_action :set_commentable, :set_term

  private
  
  def set_commentable
    @commentable = Evaluation.find(params[:evaluation_id])

    authorize @commentable.becomes(Evaluation)
  end

  def set_term
    @term = @commentable.submission.term
  end
end
  
