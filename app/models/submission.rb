class Submission < ActiveRecord::Base
  attr_accessor :student_group_id

  belongs_to :exercise
  belongs_to :submitter, :class_name => "Account", :foreign_key => "submitter_id"
  belongs_to :student_group

  has_one :submission_evaluation, dependent: :destroy
  has_many :submission_assets, inverse_of: :submission
  has_many :exercise_registrations, dependent: :destroy
  has_many :term_registrations, through: :exercise_registrations

  validates :submitter, presence: true
  validates :submitted_at, presence: true
  validates :student_group, uniqueness: {scope: :exercise_id}, if: :student_group

  validate :upload_size_below_exercise_maximum_upload_size

  scope :for_term, lambda { |term| joins(:exercise).where(exercise: {term_id: term.id}) }
  scope :for_exercise, lambda { |exercise| where(exercise_id: exercise) }
  scope :for_tutorial_group, lambda { |tutorial_group| joins {exercise_registrations.term_registration} .where { term_registrations.tutorial_group_id == my {tutorial_group.id} }}
  scope :for_student_group, lambda {|student_group| where(student_group: student_group) }
  scope :for_account, lambda {|account| joins(:term_registrations).where(term_registrations: {account_id: account.id})}
  scope :unmatched, lambda { joins{ exercise_registrations.outer }.where{exercise_registrations.id == nil} }
  scope :with_evaluation, lambda { joins(:submission_evaluation).where.not(submission_evaluation: {evaluator: nil}) }
  scope :ordered_by_student_group, lambda { references(:student_groups).order("student_groups.title ASC") }
  scope :ordered_by_exercises, lambda { joins(:exercise).order{ exercises.row_order }}

  after_create :create_submission_evaluation

  accepts_nested_attributes_for :submission_assets, allow_destroy: true, reject_if: :all_blank

  def self.next(submission, order = :id)
    Submission.where{submissions.send(my {order}) > submission.send(order)}.order(:id).order(order => :asc).first
  end

  def self.previous(submission, order = :id)
    Submission.where{submissions.send(my {order}) < submission.send(order)}.order(:id).order(order => :desc).first
  end

  def evaluated?
    submission_evaluation.present?
  end

  def result_published?
    exercise_registrations.select do |exercise_registration|
      exercise_registration.exercise.result_published_for?(exercise_registration.term_registration.tutorial_group)
    end.present?
  end

  def visible_for_student?(account)
    term_registrations.students.where(account_id: account.id).exists?
  end

  def student_group_id
    @student_group_id || student_group.try(:id)
  end

  private

  def create_submission_evaluation
    se = SubmissionEvaluation.new
    se.submission = self
    se.save!
  end

  def upload_size_below_exercise_maximum_upload_size
    size = submission_assets.map do |submission_asset|
      submission_asset.filesize
    end.sum || 0

    if exercise.enable_max_upload_size && size > exercise.maximum_upload_size
      errors.add(:base, "Upload too large")
    end
  end
end
