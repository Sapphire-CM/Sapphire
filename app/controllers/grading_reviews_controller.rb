class GradingReviewsController < ApplicationController
  include TermContext

  class GradingReviewPolicyRecord < Struct.new(:user, :term)
    def policy_class
      GradingReviewPolicy
    end
  end

  def index
    authorize GradingReviewPolicyRecord.new(current_account, current_term)

    @term_registrations = current_term.term_registrations.search(params[:q]).load if params[:q].present?
  end

  def show
    authorize GradingReviewPolicyRecord.new(current_account, current_term)

    @student_registration = current_term.term_registrations.students.find(params[:id])
    @student = @student_registration.account

    @exercises = current_term.exercises
    @submissions = @student_registration.submissions.ordered_by_exercises.includes(:exercise).includes(submission_evaluation: {evaluation_groups: [:rating_group, evaluations: :rating]})
    @grading_scale = GradingScaleService.new(current_term, [@student_registration])
  end
end
