class Exercise < ActiveRecord::Base
  belongs_to :term
  attr_accessible :title, :description, :term, :term_id, :deadline, :late_deadline,
    :submission_time, :group_exercise, :row_order_position, :group_submission,
    :enable_max_total_points, :max_total_points,
    :enable_min_required_points, :min_required_points, :submission_viewer_identifier

  include RankedModel
  ranks :row_order, with_same: :term_id

  delegate :course, to: :term

  default_scope { rank(:row_order) }
  scope :for_evaluations_table, lambda { includes(submissions: [{submission_evaluation: {evaluation_groups: [:rating_group, {evaluations: :rating}]}}, {student_group_registration: {student_group: :students}}])}

  has_many :student_group_registrations, dependent: :destroy
  has_many :student_groups, through: :student_group_registrations

  has_many :submissions
  has_many :submission_evaluations, through: :submissions
  has_many :rating_groups, dependent: :destroy
  has_many :ratings, through: :rating_groups

  validates_presence_of :title
  validates_presence_of :min_required_points, if: Proc.new { enable_min_required_points }
  validates_presence_of :max_total_points, if: Proc.new { enable_max_total_points }

  def update_points!
    self.points = self.reload.rating_groups.map{|rg| rg.max_points || rg.points}.compact.sum || 0
    self.points = max_total_points if enable_max_total_points && points > max_total_points
    self.save!
  end

  after_save :update_term_points, if: lambda { |ex| ex.points_changed? }


  def submission_viewer?
    submission_viewer_identifier.present?
  end

  def update_term_points
    term.update_points!
  end

end
