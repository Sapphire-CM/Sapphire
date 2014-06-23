class StudentResultsController < ApplicationController
  StudentResultsRecord = Struct.new :submission do
    def policy_class
      StudentResultsPolicy
    end
  end

  before_action :set_exercise_context, only: :show
  before_action :set_term_context, only: :index

  def index
    @exercises = @term.exercises
    @submissions = Submission.for_account(current_account).for_exercise(@exercise)
    @tutorial_group = current_account.tutorial_group_for_term(@term)

    authorize StudentResultsRecord.new(@submissions)
  end

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
  def set_exercise_context
    @exercise = Exercise.find(params[:exercise_id])
    @term = @exercise.term
  end

  def set_term_context
    @term = Term.find(params[:term_id])
  end
end
