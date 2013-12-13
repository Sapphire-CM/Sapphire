class GradingReviewsController < ApplicationController
  before_filter :fetch_records

  def index
    @students = @tutorial_group.students.search(params[:q]) if params[:q].present?
  end

  def show
    @student = @tutorial_group.students.find(params[:id])
    @submissions = @student.submissions.joins(:exercise).order{exercise.row_order}
  end

  private
  def fetch_records
    @tutorial_group = TutorialGroup.find(params[:tutorial_group_id])
    @term = @tutorial_group.term
  end
end
