# create_table :submissions, force: :cascade do |t|
#   t.integer  :exercise_id
#   t.datetime :submitted_at
#   t.datetime :created_at,                       null: false
#   t.datetime :updated_at,                       null: false
#   t.integer  :submitter_id
#   t.integer  :student_group_id
#   t.boolean  :outdated,         default: false, null: false
# end
#
# add_index :submissions, [:exercise_id], name: :index_submissions_on_exercise_id
# add_index :submissions, [:student_group_id], name: :index_submissions_on_student_group_id
# add_index :submissions, [:submitter_id], name: :index_submissions_on_submitter_id

class Submission < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :submitter, class_name: 'Account', foreign_key: 'submitter_id'
  belongs_to :student_group

  has_one :submission_evaluation, dependent: :destroy
  has_one :term, through: :exercise

  has_many :submission_assets, autosave: true
  has_many :exercise_registrations, dependent: :destroy, inverse_of: :submission
  has_many :term_registrations, through: :exercise_registrations
  has_many :students, through: :term_registrations, source: :account
  has_many :tutorial_groups, lambda { uniq }, through: :term_registrations
  has_many :associated_student_groups, through: :term_registrations, class_name: "StudentGroup", source: :student_group

  validates :submitter, presence: true
  validates :submitted_at, presence: true
  validates :exercise, presence: true
  validates :student_group, uniqueness: { scope: :exercise_id }, if: :student_group

  validate :upload_size_below_exercise_maximum_upload_size

  delegate :submission_viewer?, to: :exercise, allow_nil: true

  scope :for_term, lambda { |term| joins(:exercise).where(exercise: { term_id: term.id }) }
  scope :for_exercise, lambda { |exercise| where(exercise_id: exercise) }
  scope :for_tutorial_group, lambda { |tutorial_group| joins { exercise_registrations.term_registration } .where { term_registrations.tutorial_group_id == my { tutorial_group.id } } }
  scope :for_student_group, lambda { |student_group| where(student_group: student_group) }
  scope :for_term_registration, lambda { |term_registration| joins(:term_registrations).where(term_registrations: {id: term_registration}) }
  scope :for_account, lambda { |account| joins(:term_registrations).where(term_registrations: { account_id: account.id }) }
  scope :unmatched, lambda { joins { exercise_registrations.outer }.where(exercise_registrations: { id:nil }) }
  scope :with_evaluation, lambda { joins(:submission_evaluation).merge(SubmissionEvaluation.evaluated) }
  scope :ordered_by_student_group, lambda { references(:student_groups).joins(:student_group).order('student_groups.title ASC') }
  scope :ordered_by_exercises, lambda { references(:exercises).joins(:exercise).order { exercises.row_order } }
  scope :current, lambda { where(outdated: false) }
  scope :outdated, lambda { where(outdated: true) }

  accepts_nested_attributes_for :exercise_registrations, allow_destroy: true, reject_if: :all_blank

  after_create :create_submission_evaluation!

  def self.find_by_account_and_exercise(account, exercise)
    for_account(account).find_by(exercise: exercise)
  end

  def modifiable_by_students?
    !outdated? && exercise.enable_student_uploads? && exercise.before_late_deadline? && exercise.term.course.unlocked?
  end

  def evaluated?
    submission_evaluation.present?
  end

  def result_published?
    ResultPublication.where(exercise: exercise, tutorial_group_id: tutorial_groups).published.exists?
  end

  def visible_for_student?(account)
    term_registrations.students.where(account: account).exists?
  end

  def submission_assets_changed?
    submission_assets.any? { |sa| sa.changed? || sa.new_record? || sa.marked_for_destruction? }
  end

  def tree(path = nil)
    tree = SubmissionStructureService.parse_submission(self, "submission")
    tree = tree.resolve(path) if path.present?
    tree
  rescue SubmissionStructureService::FileDoesNotExist
    raise ActiveRecord::RecordNotFound
  end

  def set_exercise_of_exercise_registrations!
    exercise_registrations.each do |exercise_registration|
      exercise_registration.exercise = self.exercise
    end
  end

  private
  def upload_size_below_exercise_maximum_upload_size
    size = submission_assets.map(&:filesystem_size).sum || 0

    if exercise.present? && exercise.enable_max_upload_size && size > exercise.maximum_upload_size
      errors.add(:base, 'Upload too large')
    end
  end
end
