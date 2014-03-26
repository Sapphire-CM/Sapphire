class Submission < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :student_group_registration
  has_one :student_group, through: :student_group_registration
  has_one :submission_evaluation, dependent: :destroy

  has_many :submission_assets, inverse_of: :submission

  validates_presence_of :submitted_at, :exercise
  validates_uniqueness_of :exercise_id, scope: :student_group_registration_id

  scope :for_term, lambda { |term| joins(:exercise).where(exercise: {term_id: term.id}) }
  scope :for_exercise, lambda { |exercise| where(exercise_id: exercise) }
  scope :for_tutorial_group, lambda { |tutorial_group| joins{student_group}.where { student_group.tutorial_group == my {tutorial_group} }}
  scope :for_student_group, lambda {|student_group| joins(:student_group_registration).where{student_group_registration.student_group_id == my {student_group.id}}}
  scope :for_account, lambda {|account| joins(student_group_registration: {student_group: :student_registrations}).where{student_group_registration.student_group.student_registrations.student == my{account}}}

  after_create :create_submission_evaluation

  accepts_nested_attributes_for :submission_assets

  def self.next(submission, order = :id)
    Submission.where{submissions.send(my {order}) > submission.send(order)}.order(order => :asc).first
  end

  def self.previous(submission, order = :id)
    Submission.where{submissions.send(my {order}) < submission.send(order)} .order(order => :desc).first
  end

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
