class CommentController < ApplicationController
  
  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.account = current_account
    @comment.save

    redirect_to @commentable, notice: "Comment was successfully saved"
  end

  private
   
  def comment_params
    params.require(:comments).permit(:content)
  end
end
