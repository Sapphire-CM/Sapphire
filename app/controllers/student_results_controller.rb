class StudentResultsController < ApplicationController
  skip_after_action :verify_authorized, only: :show

  before_action :set_context

  def show
    @submission = Submission.for_account(current_account).for_exercise(@exercise).first
    if @submission.present?
      @submission_evaluation = @submission.submission_evaluation
    else
      redirect_to exercise_student_submission_path(@exercise), notice: "You have not submitted any files for grading"
    end
  end


  private
  def set_context
    @exercise = Exercise.find(params[:exercise_id])
    @term = @exercise.term
  end
end
