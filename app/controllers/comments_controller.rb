class CommentsController < ApplicationController
  before_action :set_context, only: [:show, :edit, :update, :destroy]

  def index
    authorize @commentable unless pundit_policy_authorized?

    @comment = Comment.new(commentable: @commentable)
  end

  def new
  end

  def show
  end

  def create
    @comment = Comment.new(commentable: @commentable)
    @comment.assign_attributes(comment_params)
    @comment.account = current_account
    @comment.markdown = current_account.comment_markdown_preference
    @comment.term = @term

    authorize @comment
    if @comment.save
      respond_to do |format|
        format.html { redirect_to :index, notice: "Success" }
        format.js
      end
    else
      render :new
    end
  end

  def edit
  end

  def update
    @comment.assign_attributes(comment_params)

    if @comment.save
      respond_to do |format|
        format.html { redirect_to :show, notice: "Success" }
        format.js
      end
    else
      render :edit
    end
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
    params.require(:comment).permit(:content, :name, :markdown)
  end
end
