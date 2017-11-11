# create_table :exercise_registrations, force: :cascade do |t|
#   t.integer  :exercise_id
#   t.integer  :term_registration_id
#   t.integer  :submission_id
#   t.integer  :points
#   t.datetime :created_at,           null: false
#   t.datetime :updated_at,           null: false
# end
#
# add_index :exercise_registrations, [:exercise_id], name: :index_exercise_registrations_on_exercise_id, using: :btree
# add_index :exercise_registrations, [:submission_id], name: :index_exercise_registrations_on_submission_id, using: :btree
# add_index :exercise_registrations, [:term_registration_id], name: :index_exercise_registrations_on_term_registration_id, using: :btree

class ExerciseRegistration < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :term_registration
  belongs_to :submission

  validates :exercise, presence: true
  validates :term_registration, presence: true
  validates :submission, presence: true
  validates :points, numericality: { only_integer: true }, allow_nil: true

  validates :exercise_id, uniqueness: { scope: [:term_registration_id, :submission_id] }

  before_create :update_points
  after_save :update_term_registration_points, if: :points_changed?

  scope :for_student, lambda { |student| joins(:term_registration).where(term_registration: { account_id: student.id }).merge(TermRegistration.students) }
  scope :for_exercise, lambda { |exercise| where(exercise_id: exercise.id) }
  scope :ordered_by_exercise, lambda { joins(:exercise).order { exercises.row_order } }
  scope :current, lambda { joins(:submission).merge(Submission.current) }

  def minimum_points_reached?
    !exercise.enable_min_required_points || submission.submission_evaluation.evaluation_result >= exercise.min_required_points
  end

  def update_points!
    update_points
    save!
  end

  private
  def update_points
    if submission.submission_evaluation.present?
      self.points = submission.submission_evaluation.evaluation_result
    end
  end

  def update_term_registration_points
    term_registration.update_points!
  end
end
