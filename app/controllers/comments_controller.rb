class CommentsController < ApplicationController
  def show
    authorize Comment
  end

  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.account = current_account
    @comment.term = @term

    authorize @comment
    @comment.save

    render partial: 'comment/overview', notice: "Comment successfully saved"
  end

  private
   
  def comment_params
    params.require(:comment).permit(:content)
  end
end
