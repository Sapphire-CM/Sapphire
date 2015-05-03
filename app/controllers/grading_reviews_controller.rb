class GradingReviewsController < ApplicationController
  include TermContext

  def index
    authorize GradingReviewPolicy.with current_term

    @term_registrations = current_term.term_registrations.students.search(params[:q]).load if params[:q].present?
  end

  def show
    authorize GradingReviewPolicy.with current_term

    @student_registration = current_term.term_registrations.students.find(params[:id])
    @student = @student_registration.account

    @exercises = current_term.exercises
    @submissions = @student_registration.submissions.ordered_by_exercises.includes(:exercise).includes(submission_evaluation: { evaluation_groups: [:rating_group, evaluations: :rating] })
    @grading_scale_service = GradingScaleService.new(current_term)
  end
end
