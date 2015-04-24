class StudentResultsController < ApplicationController
  include TermContext

  def index
    authorize StudentResultsPolicy.with current_term

    @term_registration = current_term.term_registrations.for_account(current_account).first
    @exercise_registrations = @term_registration.exercise_registrations.ordered_by_exercise
    @grading_scale = GradingScaleService.new(current_term)
  end

  def show
    @term_registration = current_term.term_registrations.find_by_account_id(current_account.id)
    @exercise = current_term.exercises.find(params[:id])
    @exercise_registration = @term_registration.exercise_registrations.find_by_exercise_id(@exercise.id)

    if @exercise_registration.present? && @submission = @exercise_registration.submission
      authorize StudentResultsPolicy.with @submission

      @submission_evaluation = @submission.submission_evaluation
    else
      authorize current_term

      redirect_to exercise_student_submission_path(@exercise), notice: 'You have not submitted any files for grading'
    end
  end
end
