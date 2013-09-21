class Submission < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :student_group_registration
  has_one :student_group, through: :student_group_registration
  has_one :submission_evaluation, dependent: :destroy

  has_many :submission_assets
  attr_accessible :submitted_at

  validates_presence_of :submitted_at, :exercise
  validates_uniqueness_of :exercise_id, scope: :student_group_registration_id

  scope :for_term, lambda { |term| joins(:exercise).where(exercise: {term_id: term.id}) }

  scope :for_exercise, lambda { |exercise| where(exercise_id: exercise) }

  after_create :create_submission_evaluation

  def assign_to(student_group)
    self.student_group_registration = student_group.register_for(self.exercise)
  end

  def evaluated?
    submission_evaluation.present?
  end

  private
  def create_submission_evaluation
    se = SubmissionEvaluation.new
    se.submission = self
    se.save!
  end
end
