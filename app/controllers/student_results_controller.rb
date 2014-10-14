class StudentResultsController < ApplicationController
  include TermContext

  class StudentResultsPolicyRecord < Struct.new :subject
    def policy_class
      StudentResultsPolicy
    end
  end


  def index
    authorize StudentResultsPolicyRecord.new(current_term)

    @term_registration = current_term.term_registrations.for_account(current_account).first
    @exercise_registrations = @term_registration.exercise_registrations.ordered_by_exercise
    @grading_scale = GradingScaleService.new(current_term, [@term_registration])
  end

  def show
    @term_registration = current_term.term_registrations.for_account(current_account).first
    @exercise = current_term.exercises.find(params[:id])
    @exercise_registration = @term_registration.exercise_registrations.for_exercise(@exercise).first
    @submission = @exercise_registration.submission

    authorize StudentResultsPolicyRecord.new(@submission)

    if @submission.present?
      @submission_evaluation = @submission.submission_evaluation
    else
      redirect_to exercise_student_submission_path(@exercise), notice: "You have not submitted any files for grading"
    end
  end
end
