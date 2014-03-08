class GradingReviewsController < ApplicationController
  before_action :set_context

  def index
    authorize @term

    @students = @tutorial_group.students.search(params[:q]) if params[:q].present?
  end

  def show
    authorize @term

    @student = @tutorial_group.students.find(params[:id])
    @submissions = @student.submissions.joins(:exercise).order{exercise.row_order}
  end

  private
    def set_context
      @tutorial_group = TutorialGroup.find(params[:tutorial_group_id])
      @term = @tutorial_group.term
    end
end
