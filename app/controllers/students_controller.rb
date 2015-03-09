class StudentsController < ApplicationController
  include TermContext

  def index
    authorize StudentsPolicy.with current_term

    @term_registrations = students_scope.includes(:account, :exercise_registrations, :tutorial_group, :term)
    @grading_scale = GradingScaleService.new(current_term)
  end

  def show
    authorize StudentsPolicy.with current_term

    @term_registration = students_scope.find(params[:id])
    @exercise_registrations = @term_registration.exercise_registrations.ordered_by_exercise.includes(:exercise).load

    @tutorial_group = @term_registration.tutorial_group
    @grading_scale = GradingScaleService.new(current_term)
    @student_group = @term_registration.student_group
  end

  private

  def students_scope
    current_term.term_registrations.students
  end
end
