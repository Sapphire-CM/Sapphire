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

  before_save :improve_grading_scale

  default_scope { rank(:row_order) }
  scope :associated_with, lambda { |account| joins(:term_registrations).where(term_registrations: { account_id: account.id }) }

  def associated_with?(account)
    Term.associated_with(account).where(id: id).exists?
  end

  def improve_grading_scale
    self.grading_scale = {
      0 => '5',
      51 => '4',
      64 => '3',
      80 => '2',
      90 => '1'
    }.to_a if grading_scale.empty?

    grading_scale.sort!

    grading_scale.dup.reverse.each_with_index do |_scale, index|
      grading_scale[index][1] = "#{grading_scale.length - index}"
    end

    grading_scale
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
    @grade_for_points[points] ||= grading_scale.select { |lower, _grade| lower <= points }.last[1]
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

  def update_grading_scale!(new_grading_scale)
    grading_scale.map! do |scale|
      if (scale_to_update = new_grading_scale.select { |param| scale.last == param.last }).any?
        scale_to_update.first
      else
        scale
      end
    end
    self.save!
  end
end
