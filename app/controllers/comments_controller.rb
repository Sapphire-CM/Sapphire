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
    if @comment.save
      respond_to :js
    else 
      render :show
    end
  end

  def edit
  end

  def update
    @comment.assign_attributes(comment_params)
    @comment.save

    respond_to :js
  end

  def destroy
    @comment.destroy
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
