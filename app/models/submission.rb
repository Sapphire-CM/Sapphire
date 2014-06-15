class Submission < ActiveRecord::Base
  attr_accessor :student_group_id

  belongs_to :exercise
  belongs_to :student_group_registration
  belongs_to :submitter, :class_name => "Account", :foreign_key => "submitter_id"

  has_one :student_group, through: :student_group_registration
  has_one :submission_evaluation, dependent: :destroy
  has_many :submission_assets, inverse_of: :submission

  validates_presence_of :submitted_at, :exercise
  validate :student_group_and_exercise_uniqueness

  scope :for_term, lambda { |term| joins(:exercise).where(exercise: {term_id: term.id}) }
  scope :for_exercise, lambda { |exercise| where(exercise_id: exercise) }
  scope :for_tutorial_group, lambda { |tutorial_group| joins{student_group}.where { student_group.tutorial_group == my {tutorial_group} }}
  scope :for_student_group, lambda {|student_group| joins(:student_group_registration).where{student_group_registration.student_group_id == my {student_group.id}}}
  scope :for_account, lambda {|account| joins(student_group_registration: {student_group: :student_registrations}).where{student_group_registration.student_group.student_registrations.student == my{account}}}
  scope :ordered_by_student_group, lambda { joins(:student_group).order("student_groups.title ASC") }

  before_save :assign_student_group
  after_create :create_submission_evaluation

  accepts_nested_attributes_for :submission_assets, allow_destroy: true, reject_if: :all_blank

  validate :upload_size_below_exercise_maximum_upload_size

  def self.next(submission, order = :id)
    Submission.where{submissions.send(my {order}) > submission.send(order)}.order(order => :asc).first
  end

  def self.previous(submission, order = :id)
    Submission.where{submissions.send(my {order}) < submission.send(order)} .order(order => :desc).first
  end

  def assign_to(student_group)
    self.student_group_registration = student_group.register_for(self.exercise)
  end

  def assign_to_account(account)
    student_groups = StudentGroup.for_student(account).for_term(exercise.term).active.where(solitary: !exercise.group_submission?).load
    if student_groups.count == 1
      assign_to(student_groups.first)
    else
      raise "This account (##{account.id}) has ambiguous student groups (#{student_groups.count} student groups match)"
    end
  end


  def evaluated?
    submission_evaluation.present?
  end

  def result_published?
    student_group.present? && exercise.result_published_for?(student_group.tutorial_group)
  end

  def student_group_id
    @student_group_id || student_group.try(:id)
  end

  private
  def student_group_and_exercise_uniqueness
    sg = if student_group_id.present?
      StudentGroup.find(student_group_id)
    else
      student_group
    end

    if sg
      if sg.term.present? && sg.term != exercise.term
        errors.add(:base, "Student group is not in the same term as the exercise")
      end

      other_submissions = sg.submissions
      other_submissions = other_submissions.where.not(id: id) unless new_record?

      if other_submissions.where(exercise_id: exercise.id).exists?
        errors.add(:student_group_id, "This student group has already a submission for this exercise")
      end
    end
  end

  def assign_student_group
    if student_group_id.present?
      assign_to(StudentGroup.find(student_group_id))
    end
  end

  def create_submission_evaluation
    se = SubmissionEvaluation.new
    se.submission = self
    se.save!
  end

  def upload_size_below_exercise_maximum_upload_size
    size = submission_assets.map do |submission_asset|
      submission_asset.filesize
    end.sum || 0

    if exercise.maximum_upload_size && size > exercise.maximum_upload_size
      errors.add(:base, "Upload too large")
    end
  end
end
