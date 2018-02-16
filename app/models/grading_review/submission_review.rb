class GradingReview::SubmissionReview
  include ActiveModel::Model

  attr_accessor :exercise_registration, :published

  delegate :exercise, :points, :individual_subtractions, :individual_subtractions?, :submission, :term_registration, to: :exercise_registration
  delegate :submission_evaluation, :submitted_at, :recent?, :outdated?, :exercise_attempt, to: :submission
  delegate :evaluations, to: :submission_evaluation

  delegate :tutorial_group, to: :term_registration

  delegate :title, to: :exercise, prefix: true
  delegate :achievable_points, :submission_viewer?, :row_order, to: :exercise

  def self.find_by_account_and_exercise(account, exercise)
    new(exercise_registration: ExerciseRegistration.for_exercise(exercise).for_student(account).first!)
  end

  def submission_assets
    @submission_assets ||= submission.submission_assets.order(:file)
  end

  def evaluations_visible_to_students
    evaluations.select(&:show_to_students?)
  end

  def reviewable_evaluation_groups
    @reviewable_evaluation_groups ||= build_reviewable_evaluation_groups
  end

  def deductions?
    !evaluations_visible_to_students.empty? || individual_subtractions?
  end

  def published?
    @published = fetch_result_publication_status if @published.nil?
    @published
  end

  private
  def build_reviewable_evaluation_groups
    evaluations_visible_to_students.group_by(&:evaluation_group).map do |evaluation_group, evaluations|
      GradingReview::ReviewableEvaluationGroup.new(evaluation_group: evaluation_group, evaluations: evaluations)
    end.sort_by(&:row_order)
  end

  def fetch_result_publication_status
    !!submission.result_published?
  end
end