class Term < ActiveRecord::Base
  include RankedModel
  ranks :row_order, with_same: :course_id

  enum status: [:ready, :preparing]

  belongs_to :course

  has_many :grading_scales, dependent: :destroy
  has_many :exercises, dependent: :destroy
  has_many :tutorial_groups, dependent: :destroy
  has_many :submissions, through: :exercises
  has_many :student_groups, through: :tutorial_groups
  has_many :term_registrations, dependent: :destroy
  has_many :exercise_registrations, through: :term_registrations

  has_many :imports, dependent: :destroy
  has_many :exports, dependent: :destroy

  validates :course, presence: true
  validates :title, presence: true, uniqueness: { scope: :course_id }

  default_scope { rank(:row_order) }
  scope :associated_with, lambda { |account| joins(:term_registrations).where(term_registrations: { account_id: account.id }) }

  after_create do
    grading_scales.create! [
      { grade: "ungraded", not_graded: true, positive: false },
      { grade: "5", positive: false, max_points: 50 },
      { grade: "4", min_points: 51, max_points: 60 },
      { grade: "3", min_points: 61, max_points: 84 },
      { grade: "2", min_points: 85, max_points: 90 },
      { grade: "1", min_points: 91, max_points: 100 },
    ]
  end

  def associated_with?(account)
    Term.associated_with(account).where(id: id).exists?
  end

  def update_points!
    self.points = exercises.pluck(:points).compact.sum || 0
    self.save!
  end

  def lecturers
    Account.lecturers_for_term(self)
  end

  def tutors
    Account.tutors_for_term(self)
  end

  def students
    Account.students_for_term(self)
  end

  def group_submissions?
    exercises.group_exercises.any?
  end

  def grade_for_points(points)
    @grade_for_points ||= {}
    @grade_for_points[points] ||= grading_scale.reverse.find { |lower, _grade| lower <= points }[1]
  end

  def grade_distribution(students)
    distribution = Hash.new(0)
    grades = students.map { |s| [s.grade_for_term(self), s] }

    grades.each do |v|
      distribution[v] += 1
    end
    distribution
  end

  def achievable_points
    exercises.to_a.sum(&:achievable_points)
  end

  def participated?(student)
    exercise_registrations.for_student(student).exists?
  end
end
