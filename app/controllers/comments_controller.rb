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

    render partial: 'comments/insert_comment'
  end

  def edit
  end

  def update
    @comment.assign_attributes(comment_params)
    @comment.save

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @comment.destroy
    render partial: 'comments/remove_comment', locals: { comment: @comment }
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
