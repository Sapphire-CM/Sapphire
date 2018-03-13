class GradingReview::TermReview
  include ActiveModel::Model

  def self.find_with_term_and_term_registration_id(term, id)
    new(term_registration: term.term_registrations.student.find(id))
  end

  def self.find_with_term_and_account(term, account)
    new(term_registration: term.term_registrations.student.find_by!(account: account))
  end

  attr_accessor :term_registration

  delegate :term, :points, :tutorial_group, to: :term_registration
  delegate :achievable_points, to: :term
  delegate :all_results_published?, to: :tutorial_group

  def student
    term_registration.account
  end

  def grading_scale_service
    @grading_scale_service ||= GradingScaleService.new(term)
  end

  def submission_reviews
    @submission_reviews ||= fetch_exercise_registrations.map do |exercise_registration|
      GradingReview::SubmissionReview.new(exercise_registration: exercise_registration, published: result_publications[exercise_registration.exercise].published?)
    end.sort_by(&:row_order)
  end

  def grade
    grading_scale_service.grade_for(term_registration)
  end

  def published_points
    submission_reviews.select { |submission_review| submission_review.published? && submission_review.active? }.sum(&:points)
  end

  private
  def result_publications
    @result_publications ||= fetch_result_publications
  end

  def fetch_result_publications
    ResultPublication.where(exercise: term.exercises, tutorial_group: tutorial_group).index_by(&:exercise)
  end

  def fetch_exercise_registrations
    term_registration.exercise_registrations
      .joins(:submission)
      .includes(submission: [:exercise, submission_evaluation: { evaluations: [:rating, evaluation_group: :rating_group] }])
      .merge(Submission.ordered_by_exercises)
  end
end