# create_table :exercise_registrations, force: :cascade do |t|
#   t.integer  :exercise_id
#   t.integer  :term_registration_id
#   t.integer  :submission_id
#   t.integer  :points
#   t.datetime :created_at,                              null: false
#   t.datetime :updated_at,                              null: false
#   t.integer  :individual_subtractions
#   t.boolean  :outdated,                default: false, null: false
# end
#
# add_index :exercise_registrations, [:exercise_id], name: :index_exercise_registrations_on_exercise_id
# add_index :exercise_registrations, [:submission_id], name: :index_exercise_registrations_on_submission_id
# add_index :exercise_registrations, [:term_registration_id], name: :index_exercise_registrations_on_term_registration_id

class ExerciseRegistration < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :term_registration
  belongs_to :submission, inverse_of: :exercise_registrations

  validates :exercise, presence: true
  validates :term_registration, presence: true
  validates :submission, presence: true
  validates :points, numericality: { only_integer: true }, allow_nil: true
  validates :individual_subtractions, numericality: { only_integer: true, less_than_or_equal_to: 0 }, allow_nil: true
  validates :term_registration_id, uniqueness: { scope: [:exercise_id, :submission_id] }

  before_save :update_points_before_save

  after_create :mark_similar_as_outdated!, if: :recent?
  after_update :mark_similar_as_outdated!, if: [:recent?, :outdated_changed?]

  after_save :update_term_registration_points, if: lambda { |er| er.points_changed? || er.outdated_changed? }
  after_save :update_submission_outdated, if: :outdated_changed?
  after_update :update_points_of_changed_term_registrations, if: lambda { |exercise_registration| exercise_registration.term_registration_id_changed? }
  after_destroy :update_term_registration_points

  scope :for_student, lambda { |student| joins(:term_registration).where(term_registration: { account_id: student.id }).merge(TermRegistration.students) }
  scope :for_exercise, lambda { |exercise| where(exercise_id: exercise.id) }
  scope :ordered_by_exercise, lambda { joins(:exercise).order { exercises.row_order } }
  scope :recent, lambda { where(outdated: false) }
  scope :outdated, lambda { where(outdated: true) }

  delegate :evaluation_result, to: :submission_evaluation, allow_nil: true
  delegate :submission_evaluation, to: :submission, allow_nil: true

  def minimum_points_reached?
    !exercise.enable_min_required_points || exercise.min_required_points <= points
  end

  def update_points!
    update_points
    save!
  end

  def update_points
    result_without_subtractions = evaluation_result || 0
    subtractions = individual_subtractions.presence || 0

    self.points = [result_without_subtractions + subtractions, 0].max
  end

  def recent?
    !outdated?
  end

  private

  def similar_exercise_registrations
    scope = self.class.where(term_registration: term_registration, exercise: exercise)
    scope = scope.where.not(id: id) if persisted?
    scope
  end

  def mark_similar_as_outdated!
    similar_exercise_registrations.recent.each do |exercise_registration|
      exercise_registration.update(outdated: true)
    end
  end

  def update_submission_outdated
    submission.update_outdated!
  end

  def update_points_before_save
    update_points if new_record? || individual_subtractions_changed?
  end

  def update_term_registration_points
    term_registration.update_points! if term_registration.present?
  end

  def update_points_of_changed_term_registrations
    TermRegistration.where(id: term_registration_id_change).each(&:update_points!)
  end
end
