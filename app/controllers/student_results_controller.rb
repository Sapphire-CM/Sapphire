class StudentResultsController < ApplicationController
  StudentResultsRecord = Struct.new :submission do
    def policy_class
      StudentResultsPolicy
    end
  end

  before_action :set_context

  def show
    @submission = Submission.for_account(current_account).for_exercise(@exercise).first

    authorize StudentResultsRecord.new(@submission)
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
