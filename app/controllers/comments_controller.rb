class CommentsController < ApplicationController

  before_action :set_context, only: [:edit, :update, :destroy]

  def show
    authorize Comment
  end

  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.account = current_account
    @comment.term = @term

    authorize @comment
    @comment.save

    render partial: 'comments/render_list'
  end

  def edit
  end

  def destroy
    @comment.destroy
    render partial: 'comments/render_list'
  end

  private

  def set_context
    @comment = Comment.find(params[:id])

    authorize @comment
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
