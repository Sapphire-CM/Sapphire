class TutorialGroup < ActiveRecord::Base
  belongs_to :term
  has_one :course, through: :term
  attr_accessible :title, :description

  default_scope { includes(:tutor_registration) }

  validates_presence_of :title
  validates_uniqueness_of :title, scope: :term_id

  has_one :tutor_registration, dependent: :destroy
  delegate :tutor, to: :tutor_registration, allow_nil: true

  has_many :student_groups, dependent: :destroy

  has_many :submissions, through: :student_group_registrations

  def students
    @students ||= student_groups.includes(:students).flat_map{ |sg| sg.students }.uniq
  end

  def student_has_submission_for_exercise?(student, exercise)
    @values ||= begin
      values = {}

      term.exercises.each do |ex|
        students.each do |s|
          values[s.id] ||= {}
          values[s.id][ex.id] = s.submission_for_exercise(ex).any?
        end
      end

      values
    end

    @values[student.id][exercise.id]
  end
end
