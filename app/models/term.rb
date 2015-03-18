class Term < ActiveRecord::Base
  include RankedModel
  ranks :row_order, with_same: :course_id

  serialize :grading_scale, Array
  enum status: [:ready, :preparing]

  belongs_to :course

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
  scope :associated_with, lambda {|account| joins(:term_registrations).where(term_registrations: {account_id: account.id}) }

  def lecturers
    Account.lecturers_for_term(self)
  end

  def tutors
    Account.tutors_for_term(self)
  end

  def students
    Account.students_for_term(self)
  end

  def associated_with?(account)
    Term.associated_with(account).where(id: self.id).exists?
  end

  def update_points!
    self.update! points: (exercises.to_a.sum(:points) || 0)
  end

  def group_submissions?
    exercises.group_exercises.any?
  end

  def participated?(student)
    exercise_registrations.for_student(student).exists?
  end

  def achievable_points
    exercises.to_a.sum(&:achievable_points)
  end

  def grade_distribution(students)
    distribution = Hash.new(0)
    grades = students.map { |s| [s.grade_for_term(self), s] }

    grades.each do |v|
      distribution[v] += 1
    end
    distribution
  end

  def grading_scale(term_registrations = false)
    GradingScaleService.new(self, term_registrations)
  end

  def grading_scale=(value)
    fail 'not supported'
  end

  def update_grading_scale!(grade, points)
    gs = grading_scale
    gs.update_range(grade, points)
    write_attribute(:grading_scale, gs.to_a)
    save!
  end
end
