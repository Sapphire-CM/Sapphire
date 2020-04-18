# create_table :exercises, force: :cascade do |t|
#   t.integer  :term_id
#   t.string   :title
#   t.datetime :created_at,                                        null: false
#   t.datetime :updated_at,                                        null: false
#   t.text     :description
#   t.datetime :deadline
#   t.datetime :late_deadline
#   t.boolean  :enable_max_total_points,           default: false, null: false
#   t.integer  :max_total_points
#   t.integer  :row_order
#   t.boolean  :group_submission,                  default: false, null: false
#   t.integer  :points
#   t.boolean  :enable_min_required_points,        default: false, null: false
#   t.integer  :min_required_points
#   t.string   :submission_viewer_identifier
#   t.integer  :maximum_upload_size
#   t.boolean  :enable_student_uploads,            default: true,  null: false
#   t.boolean  :enable_max_upload_size,            default: false, null: false
#   t.integer  :visible_points
#   t.string   :instructions_url
#   t.boolean  :enable_bulk_submission_management, default: false
#   t.boolean  :enable_multiple_attempts,          default: false, null: false
#   t.integer  :filesystem_size,                   default: 0
# end
#
# add_index :exercises, [:term_id], name: :index_exercises_on_term_id
# add_index :exercises, [:title, :term_id], name: :index_exercises_on_title_and_term_id, unique: true

class Exercise < ActiveRecord::Base
  include RankedModel
  include Exercises::DiskUsageStatistics

  belongs_to :term

  ranks :row_order, with_same: :term_id

  has_many :exercise_registrations, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :result_publications, dependent: :destroy
  has_many :rating_groups, dependent: :destroy
  has_many :attempts, dependent: :destroy, class_name: "ExerciseAttempt", inverse_of: :exercise
  has_many :submissions 
  
  has_many :submission_evaluations, through: :submissions
  has_many :ratings, through: :rating_groups

  has_one :default_attempt, lambda { default }, class_name: "ExerciseAttempt", inverse_of: :exercise

  default_scope { rank(:row_order) }
  scope :for_evaluations_table, lambda { includes(submissions: [{ submission_evaluation: { evaluation_groups: [:rating_group, { evaluations: :rating }] } }, { student_group_registration: { student_group: :students } }]) }

  scope :group_exercises, lambda { where(group_submission: true) }
  scope :solitary_exercises, lambda { where(group_submission: false) }
  scope :mandatory_exercises, lambda { where(enable_min_required_points: true) }

  before_save :update_points, if: lambda { |exercise| exercise.enable_max_total_points_changed? || exercise.max_total_points_changed? }
  after_create :ensure_result_publications
  after_save :update_term_points, if: :points_changed?
  after_save :recalculate_term_registrations_results, if: lambda { |exercise| exercise.enable_min_required_points_changed? || exercise.min_required_points_changed? || exercise.points_changed? }

  accepts_nested_attributes_for :attempts, allow_destroy: true

  validates :term, presence: true
  validates :title, presence: true, uniqueness: { scope: :term_id }
  validates :min_required_points, presence: true, if: :enable_min_required_points
  validates :max_total_points, presence: true, if: :enable_max_total_points
  validates :maximum_upload_size, presence: true, if: :enable_max_upload_size
  validates :deadline, presence: true, if: lambda { |_e| late_deadline.present? }
  validate :validate_deadlines_order

  delegate :course, to: :term

  def before_deadline?
    deadline.present? ? Time.now <= deadline : true
  end

  def before_late_deadline?
    late_deadline.present? ? Time.now <= late_deadline : before_deadline?
  end

  def past_deadline?
    deadline.present? ? Time.now > deadline : false
  end

  def past_late_deadline?
    late_deadline.present? ? Time.now > late_deadline : false
  end

  def within_late_submission_period?
    if deadline.present? && late_deadline.present?
      Time.now > deadline && Time.now <= late_deadline
    else
      false
    end
  end

  def update_points
    self.points = rating_groups(true).map { |rg| rg.max_points || rg.points }.compact.sum || 0
    self.points = max_total_points if enable_max_total_points && points > max_total_points
  end

  def update_points!
    update_points
    self.save!
  end

  def submission_viewer?
    submission_viewer_identifier.present?
  end

  def update_term_points
    term.update_points!
  end

  def result_publication_for(tutorial_group)
    ResultPublication.for(exercise: self, tutorial_group: tutorial_group)
  end

  def result_published_for?(tutorial_group)
    result_publication_for(tutorial_group).published?
  end

  def solitary_submission?
    !group_submission?
  end

  def achievable_points
    visible_points.presence || (enable_max_total_points ? max_total_points : starting_points_sum)
  end

  def recalculate_term_registrations_results
    TermRegistrationsPointsUpdateJob.perform_later term.id
  end

  def starting_points_sum
    rating_groups.sum(:points)
  end
   
  private
  def ensure_result_publications
    term.tutorial_groups.each do |tutorial_group|
      ResultPublication.find_or_create_by(exercise: self, tutorial_group: tutorial_group)
    end
  end

  def validate_deadlines_order
    if deadline.present? && late_deadline.present? && late_deadline < deadline
      errors.add(:late_deadline, 'must be chronological after deadline')
    end
  end 
end
