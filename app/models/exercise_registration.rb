class ExerciseRegistration < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :term_registration
  belongs_to :submission

  validates :exercise, presence: true
  validates :term_registration, presence: true
  validates :submission, presence: true
  validates :points, numericality: { only_integer: true }, allow_nil: true

  validates :exercise_id, uniqueness: { scope: [:term_registration_id, :submission_id] }

  before_create :update_points
  after_save :update_term_registration_points, if: :points_changed?

  scope :for_student, lambda { |student| joins(:term_registration).where(term_registration: { account_id: student.id }).merge(TermRegistration.students) }
  scope :for_exercise, lambda { |exercise| where(exercise_id: exercise.id) }
  scope :ordered_by_exercise, lambda { joins(:exercise).order { exercises.row_order } }

  def minimum_points_reached?
    !exercise.enable_min_required_points || submission.submission_evaluation.evaluation_result >= exercise.min_required_points
  end

  def update_points!
    update_points
    save!
  end

  private

  def update_points
    self.points = submission.submission_evaluation.evaluation_result
  end

  def update_term_registration_points
    term_registration.update_points!
  end
end
