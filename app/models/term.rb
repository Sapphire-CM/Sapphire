# create_table :terms, force: :cascade do |t|
#   t.string   :title
#   t.integer  :course_id
#   t.datetime :created_at,              null: false
#   t.datetime :updated_at,              null: false
#   t.text     :description
#   t.integer  :row_order
#   t.integer  :points,      default: 0
#   t.integer  :status,      default: 0
# end
#
# add_index :terms, [:course_id], name: :index_terms_on_course_id
# add_index :terms, [:title, :course_id], name: :index_terms_on_title_and_course_id, unique: true

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

  has_many :events, dependent: :destroy

  validates :course, presence: true
  validates :title, presence: true, uniqueness: { scope: :course_id }

  default_scope { rank(:row_order) }
  scope :associated_with, lambda { |account| joins(:term_registrations).where(term_registrations: { account_id: account.id }) }

  after_create do
    grading_scales.create! [
      { grade: '0', not_graded: true },
      { grade: '5', positive: false, max_points: 50 },
      { grade: '4', min_points: 51, max_points: 60 },
      { grade: '3', min_points: 61, max_points: 84 },
      { grade: '2', min_points: 85, max_points: 90 },
      { grade: '1', min_points: 91, max_points: 100 },
    ]
  end

  def associated_with?(account)
    Term.associated_with(account).where(id: id).exists?
  end

  def update_points!
    self.points = exercises.pluck(:points).compact.sum || 0
    self.save!
  end

  def achievable_points
    exercises.map(&:achievable_points).sum
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

  def participated?(student)
    exercise_registrations.for_student(student).exists?
  end

  def valid_grading_scales?
    gss = grading_scales.positives.ordered.to_a
    gss << grading_scales.negative
    checks = gss[0..-3].map.with_index do |gs, index|
      gs.min_points == gss[index + 1].max_points + 1
    end

    checks << (grading_scales.where(not_graded: true).length == 1)
    checks << (grading_scales.where(positive: false, not_graded: false).length == 1)
    checks << (grading_scales.where(positive: true, not_graded: false).length >= 1)

    checks.all?
  end

  def filesystem_size
    filesystem_size = 0
    self.submissions.each do |submission|
      filesystem_size += submission.submission_assets.sum("filesystem_size")
    end
    filesystem_size
  end
end
