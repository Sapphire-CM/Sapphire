class StudentsController < ApplicationController
  include TermContext

  before_action :fetch_student, only: [:show]

  class StudentsPolicyRecord < Struct.new(:user, :term)
    def policy_class
      StudentsPolicy
    end
  end

  def index
    authorize StudentsPolicyRecord.new(current_account, current_term)
    @term_registrations = students_scope.includes(:account, :exercise_registrations, :tutorial_group, :term)
    @grading_scale = GradingScaleService.new(current_term, @term_registrations)
  end

  def show
    authorize StudentsPolicyRecord.new(current_account, current_term)
    @exercise_registrations = @term_registration.exercise_registrations.ordered_by_exercise.includes(:exercise).load
    @grading_scale = GradingScaleService.new(current_term, [@term_registration])
  end

  private
  def students_scope
    current_term.term_registrations.students
  end

  def fetch_student
    @term_registration = students_scope.find(params[:id])
  end
end
