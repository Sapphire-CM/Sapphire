class ExerciseRegistration < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :term_registration
  belongs_to :submission

  validates_presence_of :exercise_id, :term_registration_id, :submission_id
  validates_numericality_of :points, only_integer: true, allow_nil: true

  before_save :update_points
  after_save :update_term_registration_points

  scope :for_student, lambda {|student| joins(:term_registration).where(term_registration: {account_id: student.id}).merge(TermRegistration.students)}

  def minimum_points_reached?
    !exercise.enable_min_required_points || submission.submission_evaluation.evaluation_result >= exercise.min_required_points
  end

  private
  def update_points
    self.points = submission.submission_evaluation.evaluation_result
  end

  def update_term_registration_points
    term_registration.update_points!
  end
end
