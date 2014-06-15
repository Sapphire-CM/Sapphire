class StudentGroup < ActiveRecord::Base
  belongs_to :tutorial_group

  has_one :term, through: :tutorial_group
  has_many :student_registrations, dependent: :destroy
  has_many :students, through: :student_registrations

  has_many :student_group_registrations
  has_many :exercises, through: :student_group_registrations
  has_many :submissions, through: :student_group_registrations

  scope :for_term, lambda { |term| joins{tutorial_group.term}.where{tutorial_group.term.id == my{term.id}} }
  scope :for_tutorial_group, lambda { |tutorial_group| where(tutorial_group_id: tutorial_group.id) }
  scope :for_student, lambda { |student| joins{student_registrations}.where{student_registrations.student == my {student}}}
  scope :active, lambda { where(active: true)}

  scope :solitary, lambda { where(solitary: true) }
  scope :multiple, lambda { where(solitary: false) }

  def submission_evaluations
    @submission_evaluations ||= SubmissionEvaluation.where{submission_id.in(my {self.submissions.joins{exercise}.where{exercise.term_id == my{term.id}}.pluck(:id)})}
  end

  def register_for(exercise)
    raise ArgumentError, "Exercise is not in same term" unless self.term == exercise.term

    self.student_group_registrations.where(exercise: exercise).first_or_create!
  end

  def update_points!
    self.points = self.submission_evaluations.pluck(:evaluation_result).sum
    self.save!
  end
end
